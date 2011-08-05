require 'open-uri'
require 'Mailer'

desc 'A rake task to send an email to the users indicating the winner of the current week'
task :send_winner_email => [:environment] do
  thisWeek = CutoffTime.get_this_week
  if thisWeek
    last_game = Game.maximum('game_time', :conditions => ["week = ?", thisWeek])
    now = Time.now
        
    if now > last_game
      recipients = Array.new

      @recips = User.find(:all)
      for recip in @recips
        if recip.email_address != ''
          recipients << recip.email_address
        end
      end
    
      if !recipients.empty?
        winner = WeeklyUserPoint.find_weekly_winner(thisWeek)
        winner_obj = WeeklyUserPoint.find_weekly_winner_object(thisWeek)
        max_points = WeeklyUserPoint.maximum('points', :conditions => ['week = ?', thisWeek])
  
        user = User.find(:first, :conditions => ['login = ?', winner_obj.login])
  
        tiebreaker = Tiebreaker.find(:first, :conditions => ['week = ? and user_id = ?', thisWeek, user.id])
        cutoff_time = CutoffTime.find(:first, :conditions => ['week = ?', (thisWeek.to_i + 1)])
  
        subject = "What? I won? Week " + thisWeek.to_s + " Football Pool Results"
    
        body = "Congratulations to our week " + thisWeek.to_s + " winner "
        body += winner.to_s + " with " 
        body += max_points.to_s + " wins and " 
        body += tiebreaker.points.to_s
        body += " tiebreaker points. "
        body += "I think I speak for all when I say you were lucky this week.\n\n"
        body += "Picks for next week can be made here: "
        body += "http://vanxftp.homisco.com:3003/pool/week_listing?week=" 
        body += (thisWeek.to_i + 1).to_s
        body += " and should be made by " + cutoff_time.cutoff_time.strftime("%a %b %d %Y %I:%M %p") + ".\n\n"
        body += "Thanks,\nAndy\n\n"

        Mailer.send_mail(recipients, subject, body)
      else
        print 'There are no email addresses to which to send!'
      end
    else
      print = 'The week ' + thisWeek.to_s + ' games haven''t finished yet.'
    end
  else
    print = 'No weeks have started.'
  end
end


task :send_test_email => :environment do
  thisWeek = CutoffTime.get_this_week
  if thisWeek
    last_game = Game.maximum('game_time', :conditions => ["week = ?", thisWeek])
        
    recipients = Array.new

    recipients << "aferris@homisco.com"
  
    if !recipients.empty?
      subject = "Who gives a crap"
      
      body = "Picks for next week can be made here: "
      body += "http://vanxftp.homisco.com:3003/pool/week_listing?" 
      body += "Thanks,\nAndy\n\n"

      Mailer.send_mail(recipients, subject, body)
    else
      print 'There are no email addresses to which to send!'
    end
  else
    print = 'No weeks have started.'
  end
end


desc 'A rake task to send an email to update the users of the current week''s standings'
task :send_update_email => :environment do
    thisWeek = CutoffTime.get_this_week
    if thisWeek
      first_game = Game.minimum('game_time', :conditions => ["week = ?", thisWeek])
      last_game = Game.maximum('game_time', :conditions => ["week = ?", thisWeek])
      now = Time.now

      if now > first_game and now < last_game
        recipients = Array.new

        # find all users with picks this week
        @picks = Pick.find(:all, :conditions => ['week = ?', thisWeek], :select => 'distinct user_id')

        if !@picks.empty?
          @recips = Array.new
          for pick in @picks
            @recips << User.find(pick.user_id)
          end
    
          # put each user in the recipient list
          @recips = User.find(:all)
          for recip in @recips
            if recip.email_address != ''
              recipients << recip.email_address
            end
          end
        end
    
        if !recipients.empty?
          max_points = WeeklyUserPoint.maximum('points', :conditions => ['week = ?', thisWeek])
          @leaders = WeeklyUserPoint.find_leaders(thisWeek, max_points)

          subject = "So you're saying I have a chance: Week " + thisWeek.to_s + " Football Pool Update"
      
          body = "Our week " + thisWeek.to_s + " leaders"
          body += " with " + max_points.to_s + " wins are:\n\n"
          body += "Name\t\t\tWins\tTiebreaker\nPick\n"
          for leader in @leaders
            user = User.find(leader.user_id)
            body += user.first_name + " " + user.last_name
            body += "\t\t" + leader.points.to_s
            tiebreaker = Tiebreaker.find(:first, :conditions => ["week = ? and user_id = ?", thisWeek, leader.user_id])
            body += "\t\t" + tiebreaker.points.to_s
            body += "\t\t" + Team.find(Pick.find(:first, :conditions => ["week = ? and user_id = ? and game_id = ?", thisWeek, leader.user_id, tiebreaker.game_id]).team_id).abbreviation
            body += "\n"
          end
  
          body += "\nThe rest of the standings are available here: " 
          body += "http://vanxftp.homisco.com:3003/pool/week_results?week="
          body += thisWeek.to_s + "\n\n"
          body += "Good luck!\n\n"
          body += "Thanks,\nAndy"

          Mailer.send_mail(recipients, subject, body)
        else
          print = 'There are no email addresses to which to send!'
        end
      else
        print = 'The week ' + thisWeek.to_s + ' update cannot be sent because it is not within the update timeframe.'
      end
    else
      print = 'No weeks have started.'
    end
  end


desc 'A rake task to send a reminder email to the users that haven''t picked yet for the current week'
task :send_reminder_email => :environment do
    nextWeek = CutoffTime.get_next_week
    if nextWeek
      @users_that_picked = Pick.find(:all, :conditions => ["week = ?", nextWeek], :select => 'distinct user_id')

      recipients = Array.new
  
      @recips = User.find(:all)
      for recip in @recips
        no_pick = 1

        for user_pick in @users_that_picked
          if user_pick.user_id == recip.id
            no_pick = 0
          end
        end

        if no_pick == 1 and recip.email_address != ''
          recipients << recip.email_address
        end
      end

      if !recipients.empty?
        cutoff_time = CutoffTime.find(:first, :conditions => ['week = ?', nextWeek])

        subject = "Week " + nextWeek.to_s + " Football Pool Picks Reminder"
    
        body = "A friendly reminder to make your week " + nextWeek.to_s + " picks!\n"
        body += "Picks close at " + cutoff_time.cutoff_time.strftime("%a %b %d %Y %I:%M %p") + ".\n\n"
  
        body += "http://vanxftp.homisco.com:3003/pool/week_listing?week=" + nextWeek.to_s + "\n\n"
        body += "Good luck!\n\n"
        body += "Thanks,\nAndy"

        Mailer.send_mail(recipients, subject, body)
      else
        print = 'Everybody picked or there are no more email addresses to which to send!'
      end
    else
      print = 'All weeks have already been played.'
    end
  end
