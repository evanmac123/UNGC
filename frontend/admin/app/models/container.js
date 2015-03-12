import Model from 'admin/lib/model';
import Ember from 'ember';

var Container = Model.extend({
  layoutRecord: null,

  layout: Ember.computed('layoutRecord', function() {
    return this.get('layoutRecord.id');
  })
});

Container.path = '/redesign/admin/api/containers';

export default Container;
