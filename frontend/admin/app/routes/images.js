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
      // TODO: optimize, because of the pagination plugin
      // if we're not on page 1 we run two queries

      controller.setProperties({
        page: 1,
        query: query
      });
    }
  }
});
