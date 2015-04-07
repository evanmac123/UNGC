import Ember from 'ember';
import Container from 'admin/models/container';
import Node from './node.js';

export default Ember.Object.extend({
  depth: 1,

  init() {
    this.set('nodes', []);
    this.nodesByContainerId = {};
    this.containersById = {};
  },

  load() {
    var depth = this.get('depth');

    Container.get().then((containers) => {
      containers.forEach((container) => this.addContainer(container));
      this.incrementProperty('depth');
    });
  },

  addContainer(container) {
    var id       = container.get('id');
    var parentId = container.get('parentContainerId');
    var node     = this.nodeForContainerId(id);
    var parentNode;

    node.set('model', container);
    node.set('hasDescendants', container.get('childContainersCount') > 0);

    if (parentId) {
      parentNode = this.nodeForContainerId(parentId);
      parentNode.get('nodes').pushObject(node);
    } else {
      this.get('nodes').pushObject(node);
    }
  },

  nodeForContainerId(id) {
    var node;

    if (node = this.nodesByContainerId[id]) {
      return node;
    }

    node = Node.create({ modelId: id });
    this.nodesByContainerId[id] = node;

    return node;
  }
});
