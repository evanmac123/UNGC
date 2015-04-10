import Ember from 'ember';
import Container from 'admin/models/container';
import Node from './node.js';

export default Ember.Object.extend({
  init() {
    this.set('nodes', []);
    this.nodesByContainerId = {};
    this.containersById = {};
  },

  load() {
    Container.get({ root: true }).then((containers) => {
      containers.forEach((container) => this.addContainer(container));
    });
  },

  refresh() {
    this.get('nodes').clear();
    this.nodesByContainerId = {};
    this.load();
  },

  moveContainer(src, dest, pos) {
    var currentParentId = src.get('parentContainerId');
    var currentParent = this.nodeForContainerId(currentParentId);
    var srcNode = this.nodeForContainerId(src.get('id'));
    var newParentId, newParent;

    if ('above' === pos || 'below' === pos) {
      newParentId = dest.get('parentContainerId');
    } else {
      newParentId = dest.get('id') || null;
    }

    if (currentParentId === newParentId) {
      return;
    }

    newParent = this.nodeForContainerId(newParentId);

    currentParent.get('nodes').removeObject(srcNode);

    if (0 === currentParent.get('nodes.length')) {
      currentParent.set('hasDescendants', false);
    }
    newParent.load().then( () => {
      newParent.get('nodes').addObject(srcNode);
      newParent.set('hasDescendants', true);

      src.set('parentContainerId', newParentId);
      src.save({ without: ['data'] });//.then(() => this.refresh());
    }).catch( (error) => {
      console.log(error);
    });
  },

  addContainer(container) {
    var id       = container.get('id');
    var parentId = container.get('parentContainerId');
    var node     = this.nodeForContainerId(id);
    var nodes, parentNode;

    node.set('model', container);
    node.set('tree', this);
    node.set('hasDescendants', container.get('childContainersCount') > 0);
    this.containersById[id] = container;

    if (parentId) {
      parentNode = this.nodeForContainerId(parentId);
      parentNode.addChild(node);
    } else {
      this.get('nodes').addObject(node);
    }
  },

  containerForId(id) {
    return this.containersById[id];
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
