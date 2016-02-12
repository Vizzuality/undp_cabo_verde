# Available for Actor and Act (search for parens, cjildren and self)
module Filterable
  extend ActiveSupport::Concern

  included do
    def filter(options)
      initialize_params(options)
      initialize_query
    end

    private

      def initialize_params(options)
        @options = Search::ActorsParams.sanitize(options)
        @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
      end

      # Table name LOCATIONS
      # Model name Localizations
      def initialize_query
        @model_name    = if @model_name.present?
                           @model_name.classify.constantize
                         else
                           self.class.name
                         end
        @relation_name = send(@relation_name) if @relation_name.present?

        @query = if @relation_name
                   @relation_name
                 else
                   @model_name.all
                 end

        @query = @query.where(type: @levels) if @levels

        if @domains.present?
          @query = @query.joins(:categories).where({ categories: { id: @domains }})
        end

        if @start_date || @end_date
          @first_date  = (Time.zone.now - 50.years).beginning_of_day
          @second_date = (Time.zone.now + 50.years).end_of_day
        end

        if @model_name.name.include?('Actor')
          if @start_date && !@end_date
            where_query = "COALESCE(locations.start_date, '#{@first_date}') >= ? OR
                           COALESCE(locations.end_date, '#{@second_date}') >= ?",
                           @start_date.to_time.beginning_of_day, @start_date.to_time.beginning_of_day

            a = @query.joins(:location).where(where_query)

            b = @query.joins(:localizations).where(where_query)

            sql = @query.connection.unprepared_statement {
              "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
            }

            @query = @model_name.from(sql)
          end

          if @end_date && !@start_date
            where_query = "COALESCE(locations.end_date, '#{@second_date}') <= ? OR
                           COALESCE(locations.start_date, '#{@first_date}') <= ?",
                           @end_date.to_time.end_of_day, @end_date.to_time.beginning_of_day

            a = @query.joins(:location).where(where_query)

            b = @query.joins(:localizations).where(where_query)

            sql = @query.connection.unprepared_statement {
              "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
            }

            @query = @model_name.from(sql)
          end

          if @start_date && @end_date
            where_query = "COALESCE(locations.start_date, '#{@first_date}') BETWEEN ? AND ? OR
                           COALESCE(locations.end_date, '#{@second_date}') BETWEEN ? AND ? AND
                           ? BETWEEN COALESCE(locations.start_date, '#{@first_date}') AND COALESCE(locations.end_date, '#{@second_date}')",
                           @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                           @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                           @start_date.to_time.beginning_of_day

            a = @query.joins(:location).where(where_query)

            b = @query.joins(:localizations).where(where_query)

            sql = @query.connection.unprepared_statement {
              "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
            }

            @query = @model_name.from(sql)
          end
        else
          if @start_date && !@end_date
            @query = @query.where("COALESCE(#{@model_name.to_s.tableize}.start_date, '#{@first_date}') >= ? OR
                                   COALESCE(#{@model_name.to_s.tableize}.end_date, '#{@second_date}') >= ?",
                                   @start_date.to_time.beginning_of_day, @start_date.to_time.beginning_of_day)
          end

          if @end_date && !@start_date
            @query = @query.where("COALESCE(#{@model_name.to_s.tableize}.end_date, '#{@second_date}') <= ? OR
                                   COALESCE(#{@model_name.to_s.tableize}.start_date, '#{@first_date}') <= ?",
                                   @end_date.to_time.end_of_day, @end_date.to_time.beginning_of_day)
          end

          if @start_date && @end_date
            @query = @query.where("COALESCE(#{@model_name.to_s.tableize}.start_date, '#{@first_date}') BETWEEN ? AND ? OR
                                   COALESCE(#{@model_name.to_s.tableize}.end_date, '#{@second_date}') BETWEEN ? AND ? AND
                                   ? BETWEEN COALESCE(#{@model_name.to_s.tableize}.start_date, '#{@first_date}') AND COALESCE(#{@model_name.to_s.tableize}.end_date, '#{@second_date}')",
                                   @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                                   @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                                   @start_date.to_time.beginning_of_day)
          end
        end

        @query = if @model_name.method_defined? :active
                   @query.filter_actives.distinct.recent
                 else
                   @query
                 end
      end
  end

  class_methods do
  end
end
