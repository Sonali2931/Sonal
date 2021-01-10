import { LightningElement } from 'lwc';

export default class SearchProduct extends LightningElement {
import serachProduct from '@salesforce/apex/SearchController.retriveProducts';

// datatable columns
const columns = [
{
    label: 'Name',
    fieldName: 'Name',
    type: 'url',
    typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
}, {
    label: 'Product Code',
    fieldName: 'ProductCode',
    type: 'text',
}, 
];
export default class CustomSearchInLWC extends LightningElement {
@track searchData;
@track columns = columns;
@track strSearchProdName;

        handleProductName(event) {
            this.strSearchProdName = event.detail.value;
            serachProds({strProdName : this.strSearchProdName})
            .then(result => {
            this.searchData = result;
        })
    }
}