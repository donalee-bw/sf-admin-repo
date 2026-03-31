import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveSelectedOutboundNumber from '@salesforce/apex/AgentOutboundNumberPreferenceService.saveSelectedOutboundNumber';
import getAgentCallCenterNumber from '@salesforce/apex/AgentOutboundNumberPreferenceService.getAgentCallCenterNumber';
export default class VoiceNumberSelector extends LightningElement {
    selectedNumber = '';
    showDropdown = false;
    isLoading = false;
    ownNumber = 'Not assigned';

    async connectedCallback() {
        const contactCenterAgentPreference = await getAgentCallCenterNumber();
        if (contactCenterAgentPreference == null) {
            this.ownNumber = 'INVALID';
            return;
        }
        console.log(contactCenterAgentPreference)
        if (contactCenterAgentPreference.Contact_Center_Number__c == '' || contactCenterAgentPreference.Contact_Center_Number__c == null){
            this.ownNumber = 'Not Assigned'
        }else{
            this.ownNumber = contactCenterAgentPreference.Contact_Center_Number__c;
        }
        if (contactCenterAgentPreference.Apply_Local_Presence__c == true) {
            this.selectedNumber = 'LOCAL_PRESENCE';
        }else{
            this.selectedNumber = 'OWN'
        }
    }
    // get numberOptions() {
    //     return [
    //         {label : `Own Number: ${this.ownNumber}` , value : this.ownNumber},
    //         { label: 'Central California : +1 559-384-0816', value: '+15593840816' },
    //         { label: 'Toll Free: +1 844-784-4719', value: '+18447844719' },
    //         { label: 'Ohio : +1 567-393-6816', value: '+15673936816' },
    //     ];
    // }

    get lstOfOptions() {
        return [
            { label: `Own Number: ${this.ownNumber}`, value: 'OWN' },
            { label: 'Local Presence Number', value: 'LOCAL_PRESENCE' }
        ]
    }

    async handleNumberChange(event) {
        try {
            this.isLoading = true;
            // console.log('This was the selected number:', event.detail.value);
            const recordUpdate = await saveSelectedOutboundNumber({ selectedNumber: event.detail.value })
            console.log(`this was the response + ${recordUpdate}`)
            if (recordUpdate == false) {
                throw new Error('Error occured');
            }
            this.selectedNumber = event.detail.value;
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong updating the phone number',
                variant: 'error',
                mode: 'sticky'
            })
            );
            console.log(error);
            console.log(error.message);
            console.log(`this was the error that has occured`)
        } finally {
            this.isLoading = false;
        }
    }
}