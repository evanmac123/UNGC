import DS from 'ember-data';

export default DS.Model.extend({
  url: DS.attr(),
  filename: DS.attr(),
  licensing: DS.attr(),
  hasLicensing: DS.attr('boolean')
});
