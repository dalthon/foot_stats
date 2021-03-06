module FootStats
  class Match < Resource
    attr_accessor :source_id, :date, :status, :referee, :stadium, :city, :state
    attr_accessor :country, :has_statistic, :has_narration, :round, :phase
    attr_accessor :cup, :group, :game_number, :live
    attr_accessor :home_team, :home_team_name, :home_score, :home_penalties_score
    attr_accessor :visitor_team, :visitor_team_name, :visitor_score, :visitor_penalties_score

    def self.all(options={})
      championship_id = options.fetch(:championship)

      request = Request.new(self,
        :Campeonato => options.fetch(:championship),
        :stream_key => "match-championship-#{championship_id}")

      response = request.parse

      return response.error if response.error?

      updated_response response, options
    end

    def self.parse_response(response)
      response['Partida'].collect do |match|
        match_object = Match.new(
          :source_id     => match['@Id'].to_i,
          :date          => match['Data'],
          :status        => match['Status'],
          :referee       => match['Arbitro'],
          :stadium       => match['Estadio'],
          :city          => match['Cidade'],
          :state         => match['Estado'],
          :country       => match['Pais'],
          :has_statistic => match['TemEstatistica'], # TODO: Need to see boolean
          :has_narration => match['TemNarracao'],    # fields.
          :round         => match['Rodada'],
          :phase         => match['Fase'],
          :cup           => match['Taca'],
          :group         => match['Grupo'],
          :game_number   => match['NumeroJogo'],
          :live          => match['AoVivo']
        )

        match['Equipe'].each do |team|
          if team['@Tipo'] == 'Mandante'
            match_object.home_team            = team['@Id'].to_i
            match_object.home_team_name       = team['@Nome']
            match_object.home_score           = team['@Placar']
            match_object.home_penalties_score = team['@PlacarPenaltis']
          else
            match_object.visitor_team            = team['@Id'].to_i
            match_object.visitor_team_name       = team['@Nome']
            match_object.visitor_score           = team['@Placar']
            match_object.visitor_penalties_score = team['@PlacarPenaltis']
          end
        end

        match_object
      end
    end

    # Return the resource name to request to FootStats.
    #
    # @return [String]
    #
    def self.resource_name
      'ListaPartidas'
    end

    # Return the resource key that is fetch from the API response.
    #
    # @return [String]
    #
    def self.resource_key
      'Partidas'
    end

    # Return the narration from a match
    #
    # @return [Array]
    #
    def narrations(options = {})
      Narration.all(options.merge(match: source_id))
    end
  end
end