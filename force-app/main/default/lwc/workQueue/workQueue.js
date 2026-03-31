import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPendingCadenceSteps from '@salesforce/apex/WorkQueueController.getPendingCadenceSteps';

const POLL_INTERVAL_MS = 30000;

const SORT_OPTIONS = [
    { label: 'Last Modified Date', value: 'LastModifiedDate' },
    { label: 'Days Overdue', value: 'DaysOverdue' },
    { label: 'Cadence Name', value: 'CadenceName' }
];

export default class WorkQueue extends LightningElement {
    cadenceGroups = [];
    isLoading = true;
    error;
    sortField = 'LastModifiedDate';
    activeTab = 'cadences';
    _pollTimer;

    // Right panel state
    selectedRecordId;
    selectedRecordName;
    selectedRecordType;
    selectedObjectApiName;

    get sortOptions() {
        return SORT_OPTIONS;
    }

    get isCadencesTab() {
        return this.activeTab === 'cadences';
    }

    get isFeedTab() {
        return this.activeTab === 'feed';
    }

    get isListTab() {
        return this.activeTab === 'list';
    }

    get showCadenceList() {
        return this.isCadencesTab && !this.isLoading && !this.error;
    }

    get hasCadenceGroups() {
        return this.cadenceGroups && this.cadenceGroups.length > 0;
    }

    get cadencesTabClass() {
        return 'wq-tab' + (this.isCadencesTab ? ' wq-tab-active' : '');
    }

    get feedTabClass() {
        return 'wq-tab' + (this.isFeedTab ? ' wq-tab-active' : '');
    }

    get listTabClass() {
        return 'wq-tab' + (this.isListTab ? ' wq-tab-active' : '');
    }

    get selectedRecordIcon() {
        return this.selectedRecordType === 'Lead' ? 'standard:lead' : 'standard:contact';
    }

    connectedCallback() {
        this.loadData();
        this._pollTimer = setInterval(() => {
            this.loadData();
        }, POLL_INTERVAL_MS);

        this.template.addEventListener('navigate', this.handleNavigateToRecord.bind(this));
        this.template.addEventListener('clicktocall', this.handleClickToCall.bind(this));
        this.template.addEventListener('startcalling', this.handleStartCalling.bind(this));
    }

    disconnectedCallback() {
        if (this._pollTimer) {
            clearInterval(this._pollTimer);
        }
    }

    async loadData() {
        try {
            const result = await getPendingCadenceSteps({ sortField: this.sortField });
            this.cadenceGroups = result;
            this.error = undefined;
        } catch (err) {
            this.error = err.body ? err.body.message : 'Failed to load cadence steps';
            console.error('WorkQueue loadData error:', err);
        } finally {
            this.isLoading = false;
        }
    }

    handleTabClick(event) {
        this.activeTab = event.currentTarget.dataset.tab;
    }

    handleSortChange(event) {
        this.sortField = event.detail.value;
        this.isLoading = true;
        this.loadData();
    }

    handleRefresh() {
        this.isLoading = true;
        this.loadData();
    }

    handleNavigateToRecord(event) {
        event.stopPropagation();
        const { targetId, targetName, targetType } = event.detail;
        this.selectedRecordId = targetId;
        this.selectedRecordName = targetName || '';
        this.selectedRecordType = targetType || (targetId && targetId.startsWith('00Q') ? 'Lead' : 'Contact');
        this.selectedObjectApiName = this.selectedRecordType === 'Lead' ? 'Lead' : 'Contact';
    }

    handleClickToCall(event) {
        event.stopPropagation();
        const { targetId, targetName, phone } = event.detail;
        // Open the record in the right panel
        this.selectedRecordId = targetId;
        this.selectedRecordName = targetName || '';
        this.selectedRecordType = targetId && targetId.startsWith('00Q') ? 'Lead' : 'Contact';
        this.selectedObjectApiName = this.selectedRecordType === 'Lead' ? 'Lead' : 'Contact';
    }

    handleStartCalling(event) {
        event.stopPropagation();
        const { targets, stepName, cadenceName } = event.detail;
        if (targets && targets.length > 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Starting Calls',
                    message: `${stepName} - ${cadenceName}: ${targets.length} target(s)`,
                    variant: 'info'
                })
            );
            const firstTarget = targets[0];
            this.selectedRecordId = firstTarget.targetId;
            this.selectedRecordName = firstTarget.targetName || '';
            this.selectedRecordType = firstTarget.targetType || 'Lead';
            this.selectedObjectApiName = this.selectedRecordType === 'Lead' ? 'Lead' : 'Contact';
        }
    }

    handleCloseRecord() {
        this.selectedRecordId = undefined;
        this.selectedRecordName = undefined;
        this.selectedRecordType = undefined;
        this.selectedObjectApiName = undefined;
    }

    handleRecordLoad() {
        // Record loaded successfully
    }
}