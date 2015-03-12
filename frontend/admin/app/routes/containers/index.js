import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return [
      {
        id: '1',
        rank: 100,
        title: 'Fruits',
        children: [
          { id: '2', rank: 1000, title: 'Oranges', parent_id: '1', children: [] },
          { id: '3', rank: 2000, title: 'Pears', parent_id: '1', children: [] },
          {
            id: '4',
            rank: 3000,
            title: 'Apples',
            parent_id: '1',
            children: [
              { id: '5', rank: 10000, title: 'Delicious', parent_id: '4', children: [] },
              { id: '6', rank: 20000, title: 'Gala', parent_id: '4', children: [] },
              { id: '7', rank: 30000, title: 'Honeycrisp', parent_id: '4', children: [] }
            ]
          }
        ]
      },
      {
        id: '8',
        rank: 200,
        title: 'Vegetables',
        children: [
          { id: '9', rank: 1000, title: 'Cucumber', parent_id: '8', children: [] },
          { id: '10', rank: 2000, title: 'Carrot', parent_id: '8', children: [] }
        ]
      }
    ];
  },

  afterModel(model) {
    var map = {};

    function addNode(node) {
      map[node.id] = node;

      if (node.children) {
        node.children.forEach(addNode);
      }
    }

    model.forEach(addNode);

    this.set('nodeMap', map);
  },

  findNode(id) {
    return this.get('nodeMap')[id];
  },

  actions: {
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
