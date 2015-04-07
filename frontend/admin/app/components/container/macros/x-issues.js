import Ember from 'ember';
import request from 'ic-ajax';

export default Ember.Component.extend({
  _onInsertElement: function() {
    request('/redesign/admin/api/taggings/issues').then( (data) => {
      this.set('items', data.data);
    });
  }.on('didInsertElement')
});

