import Ember from 'ember';
import Layout from 'admin/models/layout';

var RSVP = Ember.RSVP;

export default Ember.Route.extend({
  model() {
    return Ember.Object.create();
  },

  afterModel: function() {
    var controller = this.controllerFor('containers.new');

    return RSVP.hash({
      layouts: Layout.get()
    }).then(function(props) {
      controller.setProperties(props);
    });
  }
});
