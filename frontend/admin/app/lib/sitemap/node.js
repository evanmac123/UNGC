import Ember from 'ember';
import Container from 'admin/models/container';

export default Ember.Object.extend({
  initNodes: function() {
    this.set('nodes', []);
  }.on('init'),

  modelId: null,
  model: null,
  tree: null,
  hasDescendants: true,
  isLoading: false,

  hasMore: Ember.computed('nodes.@each', 'hasDescendants', function() {
    return this.get('nodes.length') === 0 && this.get('hasDescendants');
  }),

  addChild(node) {
    this.get('nodes').addObject(node);
  },

  load() {
    var tree = this.get('tree');

    if (!this.get('hasMore')) {
      return Ember.RSVP.resolve();
    }

    if (!this.get('model')) {
      return Ember.RSVP.resolve();
    }

    return Container.get({
      parent_container: this.get('modelId')
    }).then((containers) => {
      containers.forEach((container) => tree.addContainer(container));
    }).finally(() => {
      this.set('isLoading', false);
    });
  }
});
