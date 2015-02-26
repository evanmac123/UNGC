import Ember from 'ember';

export default Ember.Controller.extend({
  model: [
    {
      id: '1',
      rank: 100,
      title: 'Flattuses',
      children: [
        { id: '2', rank: 1000, title: 'Shart', children: [] },
        { id: '3', rank: 2000, title: 'Toot', children: [] },
        {
          id: '4',
          rank: 3000,
          title: 'Fart',
          children: [
            { id: '5', rank: 10000, title: 'Intense', children: [] },
            { id: '6', rank: 20000, title: 'Slo\'n\'Lo', children: [] },
            { id: '7', rank: 30000, title: 'Silent', children: [] }
          ]
        }
      ]
    },
    {
      id: '8',
      rank: 200,
      title: 'About Us',
      children: [
        { id: '9', rank: 1000, title: 'Investors', children: [] }
      ]
    }
  ]
});
