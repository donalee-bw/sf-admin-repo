import { LightningElement, api, wire } from 'lwc';
import {open, EnclosingUtilityId , minimize } from "lightning/platformUtilityBarApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVoiceCallRecord from '@salesforce/apex/LogDispositionUtilController.getVoiceCallRecord';
import createTaskAndRelateVoiceCall from '@salesforce/apex/LogDispositionUtilController.createTaskAndRelateVoiceCall';

export default class LogDispositionUtil extends LightningElement {
    @api recordId;
    isLoading = false;  // true later
    voiceCallId = '';
    fetchingVoiceCall = false;
    @wire(EnclosingUtilityId) utilityId;
    taskSubject = '';
    defaultSubject = '';
    //btnLoading = false;
    btnLabel = 'Save';
    relatedToWhatId = false;
    relatedToWhoId = false;
    defaultWhoId = '';
    defaultWhatId = '';
    formLoading = true;
    vendorCallKey = '';
    isSubscribed = false;
    
    
   
    renderedCallback(){
         if (this.isSubscribed) {
            return;
        }
        const toolkitApi = this.template.querySelector('lightning-service-cloud-voice-toolkit-api');
        if(!toolkitApi)return;
        toolkitApi.addEventListener('callended', async (event) => {
            try{
                
            console.log('Call ended for ID: and now I have mnade some changes in that as well', event.detail.callId);
            console.log(event);
            console.log(`above was the eventt `);
            if(event.detail.callId && this.vendorCallKey != event.detail.callId){
                this.vendorCallKey = event.detail.callId;
                await open(this.utilityId);
                const rec = await getVoiceCallRecord({vendCallKey : event.detail.callId.toString()});
                console.log(rec);
                this.voiceCallId = rec.Id;
                
                const customerPhone = rec.CallType == 'Outbound' ? rec.ToPhoneNumber : rec.FromPhoneNumber;
                if(rec.RelatedRecordId){
                    const idOfRelatedRecord = rec.RelatedRecordId;
                    console.log(`the related record id is ${idOfRelatedRecord}`)
                    const prefix = idOfRelatedRecord?.substring(0, 3);
                    if(prefix == '003' || prefix == '00Q'){
                        this.defaultWhoId = idOfRelatedRecord;
                        this.relatedToWhoId = true;
                    }else if(prefix == '001' || prefix == '006' || prefix == '500'){
                        console.log(`this was found to be true`);
                        this.defaultWhatId = idOfRelatedRecord;
                        this.relatedToWhatId =  true;
                    }
                    const relatedName = rec?.RelatedRecord?.Name;
                    if(relatedName){
                        this.defaultSubject = `Call with ${relatedName} at ${customerPhone}`
                    }else{
                        this.defaultSubject = `Call with ${customerPhone} `;
                    }
                }else{
                    this.defaultSubject = `Call with ${customerPhone} `;
                }
                 this.isLoading = false;
            }
            console.log(`this is the default subject that we have ${this.defaultSubject}`)
            }catch(error){
                this.dispatchEvent(new ShowToastEvent({ title: 'Error! Disposition error!', message: 'Refresh the page or try again later', variant: 'error' }));
                console.log(error);
                console.log(`error occured in the listener of call ended `)
                //this.isLoading = false;
            }
        });
        this.isSubscribed = true;
        console.log(`Subscribed to call ended listner`)
    }

     handleFormLoad(){
        this.formLoading = false;
    }


   getFieldValue(fields, apiName){
        if (fields?.[apiName] !== undefined) {
            return fields[apiName];
        }

        const legacyApiName = `${apiName.charAt(0).toLowerCase()}${apiName.slice(1)}`;
        return fields?.[legacyApiName];
   }

   async handleSubmit(event){
    try{
        event.preventDefault();
        this.isLoading = true;
        // this.btnLabel = 'Saving...'
        // this.btnLoading = true;
        const fields = event.detail.fields;
        console.log(fields);
        const taskDetails = {
            subject : this.getFieldValue(fields, 'Subject'),
            disposition : this.getFieldValue(fields, 'Disposition__c'),
            ownerId : this.getFieldValue(fields, 'OwnerId'),
            whoId : this.getFieldValue(fields, 'WhoId'),
            whatId : this.getFieldValue(fields, 'WhatId'),
            description : this.getFieldValue(fields, 'Description'),
            status : this.getFieldValue(fields, 'Status')
        }
        console.log(taskDetails);
        const res = await createTaskAndRelateVoiceCall({tskDetails : taskDetails , voiceCallId : this.voiceCallId == '' ? null : this.voiceCallId})
        console.log(`this was the response`)
        console.log(res)
        console.log(`this was the voice call id : ${this.voiceCallId}`)
        if(!res){
            throw new Error('Disposition save returned false');
        }
        this.dispatchEvent(new ShowToastEvent({ title: 'Dispostion Saved', message: 'Successfully saved disposition', variant: 'success' }));
    }catch(error){
        console.log(error);
        this.dispatchEvent(new ShowToastEvent({ title: 'Error! Disposition error', message: 'Please try again later', variant: 'error' }));
        console.log(`error in handle submit`);
    }finally{
        this.relatedToWhoId = false;
        this.relatedToWhatId = false;
        this.defaultWhoId = '';
        this.defaultWhatId = '';
        this.voiceCallId = '';
        this.vendorCallKey = '';
        await minimize(this.utilityId);
    }
   }
    

}