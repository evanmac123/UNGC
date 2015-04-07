// LOL the name of this file is node.js... eww.
import Ember from 'ember';

export default Ember.Object.extend({
  initNodes: function() {
    this.set('nodes', []);
  }.on('init'),

  modelId: null,
  model: null,
  hasDescendants: true
});
