import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr(),
  isWebsiteEditor: DS.attr('boolean')
});
