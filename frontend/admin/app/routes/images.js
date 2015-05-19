import Ember from 'ember';
import RouteMixin from 'ember-cli-pagination/remote/route-mixin';

export default Ember.Route.extend(RouteMixin, {
  queryParams: {
    query: {
      refreshModel: true
    }
  },

  model: function(params) {
    return this.findPaged('image',params);
  },

  actions: {
    search(query) {
      const controller = this.controllerFor('images');
      controller.set('page', 1);
      controller.set('query', query);
    }
  }
});
