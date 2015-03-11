import Ember from 'ember';
import PageForm from 'admin/models/page-form';

var RSVP = Ember.RSVP;

export default Ember.Route.extend({
  model() {
    return Ember.Object.create();
  },

  afterModel: function() {
    var controller = this.controllerFor('containers.new');

    return RSVP.hash({
      pageForms: PageForm.get()
    }).then(function(props) {
      controller.setProperties(props);
    });
  }
});
