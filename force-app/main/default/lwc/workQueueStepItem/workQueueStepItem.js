import { LightningElement, api } from 'lwc';

export default class WorkQueueStepItem extends LightningElement {
    @api target;

    get targetIcon() {
        return this.target.targetType === 'Lead' ? 'standard:lead' : 'standard:contact';
    }

    get isOverdue() {
        return this.target.daysOverdue > 0;
    }

    get overdueLabel() {
        const days = this.target.daysOverdue;
        return `${days} Day${days !== 1 ? 's' : ''} Overdue`;
    }

    handleNavigate() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                targetId: this.target.targetId,
                targetName: this.target.targetName,
                targetType: this.target.targetType
            },
            bubbles: true,
            composed: true
        }));
    }

    handleClickToCall() {
        this.dispatchEvent(new CustomEvent('clicktocall', {
            detail: {
                targetId: this.target.targetId,
                phone: this.target.phone,
                targetName: this.target.targetName
            },
            bubbles: true,
            composed: true
        }));
    }
}