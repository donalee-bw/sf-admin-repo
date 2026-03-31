import { LightningElement, track, api } from 'lwc';
import searchTerm from '@salesforce/apex/MultipleSobjectSearchLookupController.searchTerm';

export default class MultipleSobjectSearchLookup extends LightningElement {
    @api lookupLabel;
    @api isRequired;
    @api searchtype; // "Who" or "What"

    @track searchTerm = '';
    @track searchResults = [];
    @track selectedRecord = null;
    debounceTimeout;
    isLoading = false;

    @api
    reset() {
        this.searchTerm = '';
        this.searchResults = [];
        this.selectedRecord = null;
        clearTimeout(this.debounceTimeout);
    }

    get isSearchResults(){
        return this.searchResults.length > 0;
    }

    @api
    get selectedRecordId() {
        return this.selectedRecord ? this.selectedRecord.Id : null;
    }
    
    // handleSearch(event) {
    //     this.searchTerm = event.target.value.trim();
    //     this.fetchRecords();
    // }
    handleSearch(event) {
    this.searchTerm = event.target.value.trim();


    clearTimeout(this.debounceTimeout);

    this.debounceTimeout = setTimeout(() => {
        if (this.searchTerm && this.searchTerm.length >= 2) {
            console.log('in here test fetching records')
            this.fetchRecords();
        } else {
            this.searchResults = [];
        }
    }, 1000);
}

    fetchRecords() {
        this.isLoading = true;
        console.log(`this was the serach tyep right ${this.searchtype}`)
        searchTerm({ searchTerm: this.searchTerm, searchType: this.searchtype }) // Pass searchType to Apex
            .then((result) => {
                this.searchResults = result.sort((a, b) => a.Name.localeCompare(b.Name));
            })
            .catch((error) => {
                console.error('Error fetching records:', error);
                this.searchResults = [];
            })
            .finally(()=>{
                this.isLoading = false;
            });
    }

    handleSelect(event) {
        const listItem = event.target.closest('li');
    
        if (listItem && listItem.dataset.id) {
            const selectedId = listItem.dataset.id;
            this.selectedRecord = { ...this.searchResults.find(record => record.Id === selectedId) };
            this.searchTerm = this.selectedRecord.Name;
            this.searchResults = [];

            this.dispatchEvent(new CustomEvent('recordselection', {
                detail: { 
                    selectedRecordId: this.selectedRecord.Id, 
                    objectName: this.selectedRecord.objectName 
                }
            }));
        }
    }

    handleBlur() {
        setTimeout(() => this.searchResults = [], 200);
    }

    handleFocus() {
        //this.fetchRecords();
    }

    handleClear() {
        this.searchTerm = '';
        this.searchResults = [];
        this.selectedRecord = null;
    }
}