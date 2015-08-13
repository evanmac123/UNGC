import Ember from 'ember';

export default Ember.Component.extend({
  // public api
  field: null,
  labelPath: null,
  placeholder: null,
  allowClear: false,
  multiple: false,

  // XXX hack, if the value that was in the field doesn't exist anymore
  // i.e. it was deleted from the db
  // select2 will disable the field
  //
  // we have to detect this in advance and reset value to null
  // so that the user can edit it again
  _onItems: function() {
    let items = this.get('field.items');
    if (!items) {
      return;
    }
    let exists = items.any((i) => {
      let val = this.get('field.value');
      if (val instanceof Array) {
        return true;
      } else {
        let id = parseInt(i.get('id'), 10);
        return id === val;
      }
    });
    if (!exists) {
      this.set('field.value', null);
    }
  }.observes('field.items.[]')
});
