class Components::Principles
  PAYLOAD = [
    { number: 1,
      blurb: 'Businesses should support and respect the protection of internationally proclaimed human rights.',
        path: '/what-is-gc/mission/principles/principle-1'
    },

    { number: 2,
      blurb: 'Businesses should make sure that they are not complicit in human rights abuses. ',
      path: '/what-is-gc/mission/principles/principle-2'
    },

    { number: 3,
      blurb: 'Businesses should uphold the freedom of association and the effective recognition of the right to collective bargaining.',
      path: '/what-is-gc/mission/principles/principle-3'
    },

    { number: 4,
      blurb: 'Businesses should uphold the elimination of all forms of forced and compulsory labour.',
      path: '/what-is-gc/mission/principles/principle-4'
    },

    { number: 5,
      blurb: 'Businesses should uphold the effective abolition of child labour.',
      path: '/what-is-gc/mission/principles/principle-5'
    },

    { number: 6,
      blurb: 'Businesses should uphold the elimination of discrimination in respect of employment and occupation.',
      path: '/what-is-gc/mission/principles/principle-6'
    },

    { number: 7,
      blurb: 'Businesses should support a precautionary approach to environmental challenges.',
      path: '/what-is-gc/mission/principles/principle-7'
    },

    { number: 8,
      blurb: 'Businesses should undertake initiatives to promote greater environmental responsibility.',
      path: '/what-is-gc/mission/principles/principle-8'
    },

    { number: 9,
      blurb: 'Businesses should encourage the development and diffusion of environmentally friendly technologies.  ',
      path: '/what-is-gc/mission/principles/principle-9'
    },

    { number: 10,
      blurb: 'Businesses should work against corruption in all its forms, including extortion and bribery. ',
      path: '/what-is-gc/mission/principles/principle-10'
    }

  ]

  def initialize(data)
    @data = data
  end

  def data
    principle_ids.map do |i|
      PAYLOAD[i - 1]
    end
  end

  def principle_ids
    return [] unless @data[:principles]
    principles = @data[:principles]
    principles.map do |p|
      p[:principle]
    end
  end

end
