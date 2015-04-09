import Ember from 'ember';
import Container from 'admin/models/container';
import Node from './node.js';

export default Ember.Object.extend({
  init() {
    this.set('nodes', []);
    this.nodesByContainerId = {};
    this.containersById = {};
  },

  getPreloadContainerIds() {
    var json, data;
    var ids = [];

    if (!window.localStorage) {
      return [];
    }

    if (!(json = localStorage.getItem('sitemap'))) {
      return [];
    }

    data = JSON.parse(json);

    Ember.keys(data).forEach((id) => {
      if (data[id].isOpen) {
        ids.push(id);
      }
    });

    return ids;
  },

  load() {
    var promise;
    var ids = this.getPreloadContainerIds();

    if (ids.length) {
      promise = Container.get({ parent_containers: ids.join(',') });
    } else {
      promise = Container.get({ depth: '0,1' });
    }

    promise.then((containers) => {
      containers.forEach((container) => this.addContainer(container));
    });
  },

  reset() {
    this.get('nodes').clear();
    this.nodesByContainerId = {};
    this.load();
  },

  moveContainer(src, dest, pos) {
    if ('above' === pos) {
      dest.
      sitemap.moveNodeAboveNode(src, dest);
    } else if ('below' === pos) {
      sitemap.moveNodeBelowNode(src, dest);
    } else {
      sitemap.moveNodeInsideNode(src, dest);
    }
  },

  addContainer(container) {
    var id       = container.get('id');
    var parentId = container.get('parentContainerId');
    var node     = this.nodeForContainerId(id);
    var parentNode;

    node.set('model', container);
    node.set('tree', this);
    node.set('hasDescendants', container.get('childContainersCount') > 0);
    this.containersById[id] = container;

    if (parentId) {
      parentNode = this.nodeForContainerId(parentId);
      parentNode.get('nodes').pushObject(node);
    } else {
      this.get('nodes').pushObject(node);
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
