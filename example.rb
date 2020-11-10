require 'csv'
require 'set'
require 'date'
require 'time'
require 'pp'
# processing data from Stanford Open Policing Project data:
# https://openpolicing.stanford.edu/data/


def outcome_types(filename)
    result = Set.new
    # Note that:
    # %i[numeric date] == [:numeric, :date]
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result << row['outcome']
    end
    return result
end


def outcome_types2(filename)
    # uses inject in a clever way!
    result = CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
    return result
end

def outcome_types3(filename)
    # can just return the result of the inject() call
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
end


def any_type_set(filename, key)
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row[key]
    end
end


def day_of_week(filename)
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        date = row['date']
        result[date.cwday] += 1
    end
    return result
end

def year_of_record(filename)
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        date = row['date']
        if (date !='NA')
            result[date.year] += 1
        end
    end
    return result
end



def any_type_hash(filename, key)
    # key is the name of any column header for a row
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result[row[key]] += 1
    end
    return result
end


def cwday(date)
    return date.cwday
end


def hour(time)
    return time.split(':')[0].to_i
end


def any_type_hash2(filename, key, func=nil)
    # func is a function that does more processing on a column value
    # so for example, we may want to convert a time like "19:30:56" to just 19
    # or get the day of the week for a date like "2017-03-12"
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
    end
    return result
end


def any_type_hash3(filename, key, func=nil)
    # Using inject() is tricky with a Hash
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Hash.new(0)) do |result, row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
        # THIS LINE IS NECESSARY! inject() needs a return value after processing
        # each row to assign to the next version of result
        result
    end
end

def question_one_comparison(filename)
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        date = row['date']
        if (date !='NA')
            if (date.year >2011 && date.year < 2017)
                result[date.year] += 1
            end
        end
    end
    return result
end

def question_two_comparison(filename)
    years = Hash.new{ |h,k| h[k] = Hash.new(0) } 
    racebreak = Hash.new()
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        date = row['date']
        race = row['subject_race']
        if (date !='NA')
            years[date.year] [race] += 1
        end
    end
    return years
end

def question_three_comparison(filename, key1, key2)
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        race = row[key1]
        number_of_years = row[key2]
        if (race =='NA')
            if (number_of_years != 'NA' && number_of_years >= 0)
                if (number_of_years.between?(0,5))
                    result['0-5'] += 1
                end
                if (number_of_years.between?(6,10))
                    result['6-10'] += 1
                end
                if (number_of_years.between?(11,15))
                    result['11-15'] += 1
                end
                if (number_of_years.between?(16,20))
                    result['16-20'] += 1
                end
                if (number_of_years.between?(21,25))
                    result['21-25'] += 1
                end
                if (number_of_years.between?(26,30))
                    result['26-30'] += 1
                end
                if (number_of_years.between?(31,35))
                    result['31-35'] += 1
                end
                if (number_of_years.between?(36,40))
                    result['36-40'] += 1
                end
            end
        end
    end
    return result
end


def parse_all(filename)
    outcomes = Hash.new(0)
    days = Hash.new(0)
    hours = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        outcomes[row['outcome']] += 1
        days[row['date'].cwday] += 1
        hours[hour(row['time'])] += 1
    end
    puts outcomes
    puts days
    puts hours
end

def type_breakdown(filename, key)
    #counts number of occurences, used currently for race and gender
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        type = row[key]
        result[type] += 1
        end
    return result
end

def grab_column(filename,key)
    #grabs a column from the CSV file and returns it
    col_data = []
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) {|row|
        if (row[key].is_a? Fixnum)
            col_data << row[key]
        end
    }
    col_data
end


def age_breakdown(filename)
    #calculates the age breakdowns for each city
    data = grab_column(filename, 'subject_age')
    #data.each{|x| puts x.class}
    lowest = data.min
    highest = data.max
    total = data.inject(:+)
    len = data.length
    average = total.to_f / len # to_f so we don't get an integer result
    sorted = data.sort
    median = sorted[(data.length - 1) / 2] + sorted[data.length / 2] / 2.0

    puts "The lowest age of a person stopped is: " + lowest.to_s
    puts "The highest age of a person stopped is: " + highest.to_s
    puts "The average age of a person stopped is: " + average.round(2).to_s
    puts "The median age of a person stopped is: " + median.to_s
end



if __FILE__ == $0
    chicago = 'il_chicago_2020_04_01.csv'
    tampa = 'fl_tampa_2020_04_01.csv'

    #shorter files for testing, uncomment to use:
    chicago = 'il_chicago_short_2020_04_01.csv'
    tampa = 'fl_tampa_short_2020_04_01.csv'

    #p outcome_types(chicago)

    print 'chicago: '
    p any_type_set(chicago,'outcome').sort
    print 'tampa: '
    p any_type_set(tampa,'outcome').sort
    puts "\n"
    #p outcome_types2(vt)
    #p outcome_types3(vt)
    #p any_type_set(vt, 'outcome')
    #p any_type_set(vt, 'raw_race')
    #p any_type_set(chicago, 'subject_race')
    
    #p day_of_week(chicago).sort_by(&:first).map(&:last)
    #p any_type_hash(tampa, 'violation')

    #this stores the hash of race counts sorted by key (A-Z) into the following variables
    race_breakdown1 = Hash[type_breakdown(chicago,'subject_race').sort]
    race_breakdown2 = Hash[type_breakdown(tampa, 'subject_race').sort]

    #this stores the hash of the race percentages, removing all "NA" entries from the list (as they would mess up the percentages)
    race_precentage1 = race_breakdown1.select{|x| x != "NA"}.map {|x,y| [x,(y*1.0/(race_breakdown1.dup.tap{ |hs| hs.delete("NA")}).values.sum)*100]}
    race_precentage2 = race_breakdown2.map {|x,y| [x,(y*1.0/race_breakdown2.values.sum)*100]}
    #rounds the percentages to 2 decimal points and stores that as well
    rounded_percentage1 = race_precentage1.map{ |x,y| [x,y.round(2)] }
    rounded_percentage2 = race_precentage2.map{ |x,y| [x,y.round(2)] }

    #basically the same as the above but with gender
    gender_breakdown1 = type_breakdown(chicago,'subject_sex')
    gender_breakdown2 = type_breakdown(tampa, 'subject_sex')
    #this stores the hash of the gender percentages, removing all "NA" entries from the list (as they would mess up the percentages)
    gender_precentage1= gender_breakdown1.select{|x| x != "NA"}.map {|x,y| [x,(y*1.0/gender_breakdown1.values.sum)*100]}
    gender_precentage2= gender_breakdown2.select{|x| x != "NA"}.map {|x,y| [x,(y*1.0/gender_breakdown2.values.sum)*100]}
    #rounds the percentages to 2 decimal points and stores that as well
    gender_rounded_percentage1 = gender_precentage1.map{ |x,y| [x,y.round(2)] }
    gender_rounded_percentage2 = gender_precentage2.map{ |x,y| [x,y.round(2)] }

    puts 'Race breakdowns:'
    puts "\n"
    puts 'Chicago raw race breakdown'
    pp race_breakdown1
    puts "\n"
    puts 'Chicago percentage race breakdown'
    pp rounded_percentage1
    puts "\n"
    puts 'Tampa raw race breakdown'
    pp race_breakdown2
    puts "\n"
    puts 'Tampa percentage race breakdown'
    pp rounded_percentage2
    puts "\n"
    
    puts 'Gender breakdowns:'
    puts "\n\n"
    puts 'Chicago raw gender breakdown'
    pp gender_breakdown1
    puts "\n"
    puts 'Chicago percentage gender breakdown'
    pp gender_rounded_percentage1
    puts "\n"
    puts 'Tampa raw gender breakdown'
    pp gender_breakdown2
    puts "\n"
    puts 'Tampa percentage gender breakdown'
    pp gender_rounded_percentage2
    puts "\n"

    puts 'Age Breakdown:'
    puts 'CHICAGO'
    age_breakdown(chicago)
    puts 'TAMPA'
    age_breakdown(tampa)

    puts "\n\n"

    puts 'Number of Arrests over time:'
    puts 'CHICAGO'
    pp question_one_comparison(chicago)
    puts 'TAMPA'
    pp question_one_comparison(tampa)

    puts 'Number of stops by race over time for Chicago:'
    races_over_time = Hash[question_two_comparison(chicago).sort]
    pp races_over_time

    puts 'Question 3: Chicago Missing cases vs years of service'
    pp question_three_comparison(chicago,"subject_race", "officer_years_of_service")

    #p any_type_hash2(vt, 'date', method(:cwday)).sort_by(&:first).map(&:last)
    #p any_type_hash2(vt, 'outcome')
    #p any_type_hash2(chicago, 'violation')
    #p any_type_hash2(vt, 'time', method(:hour)).sort_by(&:first).map(&:last)

    #parse_all(vt)

end