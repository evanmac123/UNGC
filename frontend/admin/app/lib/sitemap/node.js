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

  load: function() {
    var promise;
    var tree = this.get('tree');

    if (!this.get('hasMore')) {
      return;
    }

    if (!this.get('model')) {
      return;
    }

    promise = Container.get({
      parent_container: this.get('modelId')
    });

    promise.then((containers) => {
      containers.forEach((container) => tree.addContainer(container));
    });

    promise.always(() => {
      this.set('isLoading', false);
    });
  }
});
