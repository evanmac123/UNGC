import Ember from 'ember';
import Container from 'admin/models/container';
import Sitemap from 'admin/lib/sitemap/tree';

export default Ember.Route.extend({
  model: function() {
    return Sitemap.create();
  },

  afterModel(sitemap) {
    sitemap.load();
  },

  actions: {
    addContainer(parentContainer) {
      if (parentContainer) {
        this.transitionTo('containers.new', parentContainer.get('id'));
      } else {
        this.transitionTo('containers.new', 'root');
      }
    },

    moveNodes(sourceNodeId, position, targetNodeId) {
      var sourceNode = this.findNode(sourceNodeId);
      var targetNode = this.findNode(targetNodeId);
      var route      = this;
      var targetContainer;
      var targetIdx;

      function getContainer(node) {
        if (node.parent_id) {
          return route.findNode(node.parent_id).children;
        } else {
          return route.modelFor('sitemap');
        }
      }

      getContainer(sourceNode).removeObject(sourceNode);

      if (position === 'before') {
        targetContainer = getContainer(targetNode);
        targetIdx       = targetContainer.indexOf(targetNode);
        targetContainer.insertAt(targetIdx - 1, sourceNode);
      } else if (position === 'after') {
        targetContainer = getContainer(targetNode);
        targetIdx       = targetContainer.indexOf(targetNode);
        targetContainer.insertAt(targetIdx, sourceNode);
      } else if (position === 'inside') {
        targetNode.children.push(sourceNode);
      } else {
        throw 'unknown position: ' + position;
      }
    }
  }
});
