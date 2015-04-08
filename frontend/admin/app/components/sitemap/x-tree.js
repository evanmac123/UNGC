import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'ul',
  classNames: 'sitemap-x-tree',

  actions: {
    addContainerWithContext(node) {
      var parent;

      if (node) {
        parent = node.get('model');
      }

      this.sendAction('addContainer', parent);
    }
  }
});
