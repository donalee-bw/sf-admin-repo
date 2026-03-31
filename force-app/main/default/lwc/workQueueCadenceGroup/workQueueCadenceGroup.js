import { LightningElement, api } from 'lwc';

const STEP_TYPE_ICONS = {
    Call: 'utility:call',
    Email: 'utility:email',
    SendEmail: 'utility:email',
    CreateTask: 'utility:task',
    CustomStep: 'utility:custom_apps',
    Wait: 'utility:clock',
    LinkedIn: 'utility:socialshare'
};

export default class WorkQueueCadenceGroup extends LightningElement {
    _cadenceGroup;
    isExpanded = true;

    @api
    get cadenceGroup() {
        return this._cadenceGroup;
    }
    set cadenceGroup(value) {
        if (value) {
            this._cadenceGroup = {
                ...value,
                stepGroups: value.stepGroups.map(sg => ({
                    ...sg,
                    iconName: STEP_TYPE_ICONS[sg.stepType] || 'utility:task',
                    isCallStep: sg.stepType === 'Call'
                }))
            };
        }
    }

    get chevronIcon() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleExpand() {
        this.isExpanded = !this.isExpanded;
    }

    handleStartCalling(event) {
        const stepName = event.currentTarget.dataset.stepName;
        const stepGroup = this._cadenceGroup.stepGroups.find(sg => sg.stepName === stepName);
        if (stepGroup && stepGroup.targets.length > 0) {
            this.dispatchEvent(new CustomEvent('startcalling', {
                detail: {
                    targets: stepGroup.targets,
                    stepName: stepGroup.stepName,
                    cadenceName: this._cadenceGroup.cadenceName
                },
                bubbles: true,
                composed: true
            }));
        }
    }
}