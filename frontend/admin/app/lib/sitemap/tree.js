import Ember from 'ember';
import Container from 'admin/models/container';
import Node from './node';

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

  isDescendant(src, dest) {
    var parentIds = [];
    var parent = this.containerForId(dest.get('parentContainerId'));
    while(parent) {
      parentIds.push(parent.get('id'));
      parent = this.containerForId(parent.get('parentContainerId'));
    }
    if (parentIds.indexOf(src.get('id')) !== -1) {
      return true;
    }
    return false;
  },

  moveContainer(src, dest, pos) {
    var currentParentId = src.get('parentContainerId');
    var currentParent = this.nodeForContainerId(currentParentId);
    var currentId = src.get('id');
    var srcNode = this.nodeForContainerId(src.get('id'));
    var newParentId, newParent;

    if ('above' === pos || 'below' === pos) {
      newParentId = dest.get('parentContainerId');
    } else {
      newParentId = dest.get('id') || null;
    }

    // We need to make sure we're not trying to add the current page
    // to one of its children
    if (this.isDescendant(src, dest)) {
      return;
    }

    // can't drag on the same parent
    if (currentParentId === newParentId) {
      return;
    }

    // can't drag on itself
    if (currentId === newParentId) {
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
