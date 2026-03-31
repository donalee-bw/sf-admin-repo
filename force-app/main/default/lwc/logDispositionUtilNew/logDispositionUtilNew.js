import { LightningElement, api, wire,track } from 'lwc';
import { open, EnclosingUtilityId, minimize } from "lightning/platformUtilityBarApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import getVoiceCallRecord from '@salesforce/apex/LogDispositionUtilNewController.getVoiceCallRecord';
import createTaskAndRelateVoiceCall from '@salesforce/apex/LogDispositionUtilNewController.createTaskAndRelateVoiceCall';
import getDispositionPicklistValues from '@salesforce/apex/LogDispositionUtilNewController.getDispositionPicklistValues';
import getStatusValues from '@salesforce/apex/LogDispositionUtilNewController.getStatusValues';


export default class LogDispositionUtil extends LightningElement {

    @api recordId;
    userId = USER_ID;

    @wire(EnclosingUtilityId) utilityId;

    isLoading = true;
    formLoading = true;
    noActiveCall = true;

    voiceCallId = '';
    vendorCallKey = '';
    isSubscribed = false;

    btnLabel = 'Save';

    dispositionOptions = [];
    statusValues = [];

    // ✅ SINGLE SOURCE OF TRUTH
    @track formData = {
        subject: '',
        disposition: '',
        ownerId: USER_ID,
        whatId: '',
        whoId: '',
        description: '',
        status: ''
    };

    connectedCallback() {
        this.loadDispositionValues();
    }



// When user selects a WhoId (Contact or Lead)
handleWhatSelect(event) {
    this.formData = {
        ...this.formData,
        whatId: event.detail.selectedRecordId
    };
    console.log('handleWhoSelection method called');
    console.log(event.detail);
    
}

// When user selects a WhatId (Account, Case, Contact, Lead)
handleWhoSelect(event) {
    this.formData = {
        ...this.formData,
        whoId: event.detail.selectedRecordId
    };
    console.log('handleWhatSelection method called');
    console.log(event.detail);

}

handleOwnerChange(event) {
    this.formData = {
        ...this.formData,
        ownerId: event.detail.selectedRecordId
    };
    console.log('handleOwnerChange method called');
    console.log(event.detail);

}

    async loadDispositionValues() {
        try {
            const data = await getDispositionPicklistValues();
            const statusDat = await getStatusValues();

            this.statusValues = statusDat.map(val => ({
                label: val,
                value: val
            }));

            this.dispositionOptions = data.map(val => ({
                label: val,
                value: val
            }));

            if (data.length > 0) {
                this.formData = {
                    ...this.formData,
                    disposition: data[0]
                };
            }
            if(statusDat.length > 0){
                this.formData ={
                    ...this.formData,
                    status : statusDat[0]
                }
            }

        } catch (error) {
            console.error(error);
        } finally {
            this.formLoading = false;
        }
    }

    // 🔹 HANDLE INPUT CHANGE
    handleChange(event) {
        const field = event.target.dataset.field;

        this.formData = {
            ...this.formData,
            [field]: event.target.value
        };
    }

    // 🔹 VOICE EVENT LISTENER
    renderedCallback() {
        if (this.isSubscribed) return;

        const toolkitApi = this.template.querySelector('lightning-service-cloud-voice-toolkit-api');
        if (!toolkitApi) return;

        toolkitApi.addEventListener('callended', async (event) => {
            try {
                if (!event.detail.callId || this.vendorCallKey == event.detail.callId) return;

                this.vendorCallKey = event.detail.callId;
                this.isLoading = true;
                

                await open(this.utilityId);  

                const rec = await getVoiceCallRecord({
                    vendCallKey: event.detail.callId.toString()
                });
                console.log(rec)
                console.log(`this wqas the rec above`)
                if(!rec)return;
                //if(rec.CallType == 'Inbound' && rec.CallDurationInSeconds == null)return;  
                this.noActiveCall = false;
                this.voiceCallId = rec.Id;
                console.log(`this was the call duration right`);
                console.log(rec.CallDurationInSeconds);
                console.log('here')

                const phone = rec.CallType == 'Outbound'
                    ? rec.ToPhoneNumber
                    : rec.FromPhoneNumber;

                let subjectText = `Call with ${phone}`;

                if (rec.RelatedRecordId) {

                    const id = rec.RelatedRecordId;
                    const prefix = id.substring(0, 3);

                    // WHO (Contact/Lead)
                    if (prefix === '003' || prefix === '00Q') {
                        this.formData = { ...this.formData, whoId: id };
                    }

                    // WHAT (Account/Opportunity/Case)
                    if (prefix === '001' || prefix === '006' || prefix === '500') {
                        this.formData = { ...this.formData, whatId: id };
                    }

                    if (rec.RelatedRecord?.Name) {
                        subjectText = `Call with ${rec.RelatedRecord.Name} at ${phone}`;
                    }
                }

                this.formData = {
                    ...this.formData,
                    subject: subjectText,
                    ownerId: USER_ID
                };
                this.isLoading = false;
                console.log(this.formData);
                console.log(`this was the form data initially`);

            } catch (error) {
                console.error(error);
                console.log('above was teh error');
                this.showToast('Error', 'Failed to fetch call data', 'error');
            } finally {
                
            }
        });

        this.isSubscribed = true;
    }

    // 🔹 SUBMIT
    async handleSubmit() {
        try {
            console.log(`in the handlesubmti thing`)
            this.isLoading = true;
            console.log(this.formData);
            console.log(`these were the iniital project `);

            const res = await createTaskAndRelateVoiceCall({
                tskDetails: this.formData,
                voiceCallId: this.voiceCallId || null
            });

            if (!res) throw new Error('Save failed');

            this.showToast('Success', 'Disposition saved', 'success');
            this.noActiveCall = true;
        } catch (error) {
            console.log('in the error clause')
            console.error(error);
            console.log('above was the erro caluse')
            console.log(error);
            this.showToast('Error', 'Please try again', 'error');
            this.isLoading = false;
            this.noActiveCall = false;
        } finally {
            this.resetForm();
            await minimize(this.utilityId);
            
        }
    }

    // 🔹 RESET
    resetForm() {
        this.formData = {
            subject: '',
            disposition: this.formData.disposition,
            ownerId: USER_ID,
            whatId: '',
            whoId: '',
            description: '',
            status: ''
        };

        const lookups = this.template.querySelectorAll('c-multi-select-combobox');
    console.log('found lookups:', lookups.length); 
    
    lookups.forEach(lookup => {
        lookup.reset();
    })

        this.voiceCallId = '';
        this.vendorCallKey = '';
    }

    // 🔹 TOAST
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}