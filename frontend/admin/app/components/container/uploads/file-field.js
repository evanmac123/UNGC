import Ember from 'ember';

export default Ember.Component.extend({
  // default action
  upload: 'submit',

  selectedFile: null,

  didInsertElement: function() {
    this.$().on('change', event => {
      this.set("selectedFile", event.target.files);
      // Ember.run.next(function() {
      //   component.sendAction('selected');
      // });
    });
  },

  willDestroyElement: function() {
    this.$().off('change');
  },

  actions: {

    upload: function() {
      if (this.get("selectedFile")) {
        this.sendAction('upload');
      } else {
        alert("Please select a file");
      }
    }

  }
});
