import { LightningElement, track, api } from 'lwc';
import searchTerm from '@salesforce/apex/MultipleSobjectSearchLookupController.searchTerm';

export default class MultipleLookup extends LightningElement {
    @api lookupLabel;
    @api isRequired;
    @track searchTerm = '';
    @track searchResults = [];
    @track selectedRecord = null;
    debounceTimeout;
    isLoading = false;

    get isSearchResults(){
        return this.searchResults.length > 0;
    }

    @api
    get selectedRecordId() {
        return this.selectedRecord ? this.selectedRecord.Id : null;
    }
    
    @api
    get selectedRecordObjectName() {
        return this.selectedRecord && this.selectedRecord.iconName
            ? this.selectedRecord.iconName.split(':')[1] || null
            : null;
    }

    @api 
    validate() {
        if (this.isRequired && !this.selectedRecordId) {
            return {
                isValid: false,
                errorMessage: `${this.lookupLabel} is required. Please select a value.`
            };
        }
        return { isValid: true };
    }
    

    handleSearch(event) {
        this.searchTerm = event.target.value.trim();

        if (this.debounceTimeout) {
            clearTimeout(this.debounceTimeout);
        }

        this.debounceTimeout = setTimeout(() => {
            this.fetchRecords();
        }, 300);
    }

    fetchRecords() {
        this.isLoading = true;
        searchTerm({ searchTerm: this.searchTerm })
            .then((result) => {
                this.searchResults = result.sort((a, b) => a.Name.localeCompare(b.Name));
            })
            .catch((error) => {
                console.error('Error fetching records:', error);
                this.searchResults = [];
            })
            .finally(()=>{
                this.isLoading = false;
            })
    }

    handleSelect(event) {
        const listItem = event.target.closest('li');
    
        if (listItem && listItem.dataset.id) {
            const selectedId = listItem.dataset.id;
    
            this.selectedRecord = { ...this.searchResults.find(record => record.Id === selectedId) };
            const passEventr = new CustomEvent('recordselection', {
                detail: { selectedRecordId: this.selectedRecord.Id, objectName : this.selectedRecord.iconName.split(':')[1] }
            });
            this.dispatchEvent(passEventr);
            this.searchTerm = this.selectedRecord.Name;
            this.searchResults = [];
        }
    }

    handleBlur() {
        setTimeout(() => {
            this.searchResults = [];
        }, 500);
    }

    handleFocus() {
        this.fetchRecords();
    }

    handleClear() {
        this.searchTerm = '';
        this.searchResults = [];
        this.selectedRecord = null;
    }
}