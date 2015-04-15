import Ember from 'ember';
import DS from 'ember-data';
import request from 'ic-ajax';

export default Ember.Object.extend({
  data: DS.PromiseArray.create({
    promise: request('/redesign/admin/api/taggings/sectors').then( (data) => {
      return data.data;
    })
  })
});
