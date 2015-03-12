import Model from 'admin/lib/model';
import Ember from 'ember';

var Container = Model.extend({
  layoutRecord: null,

  layout: Ember.computed('layoutRecord', function() {
    return this.get('layoutRecord.id');
  }),

  initData: function() {
    if (this.get('data')) {
      return;
    }

    this.set('data', Ember.Object.create());
  }.on('init')
});

Container.path = '/redesign/admin/api/containers';
Container.type = 'container';
Container.attributes = [
  'slug',
  'layout',
  'data'
];

export default Container;
