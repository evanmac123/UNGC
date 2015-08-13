import Model from 'sitemap/lib/model';
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
  }.on('init'),

  // XXX override putData to avoid resetting properties in case of success
  // otherwise fields become unbound
  putData(opts = {}) {
    if (!this.get('id')) {
      throw 'can\'t put non-existant resource';
    }

    return this.xhr({
      type: 'PUT',
      data: this.asJSON(opts)
    }).then(
      () => {
        return this;
      }
    );
  },

  publish() {
    return this.save().then(() => {
      return this.xhr({
        type: 'POST',
        url: this.get('resourcePath') + '/publish'
      });
    });
  }
});

Container.path = '/sitemap/api/containers';
Container.type = 'container';
Container.attributes = [
  'slug',
  'publicPath',
  'layout',
  'parentContainerId',
  'draggable',
  'data',
];

Container.reopenClass({
  needsApproval() {
    return this.get('needs_approval');
  }
});

export default Container;
