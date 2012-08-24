module PetitionsHelper
  extend Memoist

  def open_graph_for(petition, hash)
    member = Member.find_by_hash(hash)
    {
      'og:title' => petition.experiments.facebook(member).title,
      'og:type' => 'watchdognet:petition',
      'og:description' => petition.facebook_description_for_sharing.html_safe,
      'og:image' => petition.experiments.facebook(member).image,
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
  end

  def counter_size(signature_count)
    [  5,     10,     50,     100,
      250,   500,    750,    1000,
     2000,  5000,   7500,   10000,
    15000, 20000, 100000, 1000000].
    find { |n| signature_count < n }
  end

  def choose_form_based_on_browser
    really_ie? ? 'ie_form' : 'form'
  end

  def facebook_sharing_option
    return 'facebook_popup' if browser.ie7?
    spin! 'facebook sharing options', :referred_member, ['facebook_popup', 'facebook_request']
  end

  def facebook_button
    button_hash = {
      'facebook_share' => { button_class: 'fb_share', button_text: 'Share on Facebook' },
      'facebook_popup' => { button_class: 'fb_popup_btn', button_text: 'Share on Facebook' },
      'facebook_wall' => { button_class: 'fb_widget_btn', button_text: 'Share with your friends' },
      'facebook_request' => { button_class: 'fb_request_btn', button_text: 'Send request to friends' }
    }
    button_hash[facebook_sharing_option] || button_hash['facebook_popup']
  end

  def after_share_view
    return 'thanks_for_signing' if browser.ie? or browser.mobile? or browser.android?
    spin! 'after share view 2', :share, ["thanks_for_signing", "button_is_most_effective_tool", "tell_two_friends", "signatures_stop_signatures_multiply", "signatures_stop_signatures_multiply_with_thanks"]
  end

  def progress_option
    spin! 'test different messaging on progress bar', :signature, progress_options_config.keys
  end

  def progress
    progress_options_config[progress_option] || {text: '', classes: ''}
  end

  def countdown_to_share?
    spin! 'display countdown to share', :share
  end

  private

  def really_ie?
    browser.ie? && !(browser.user_agent =~ /chromeframe/)
  end

  def social_media_config
    Rails.configuration.social_media
  end

  def progress_options_config
    {
      'x_signatures_of_y' => {
        :text => "#{@sigcount} signatures\nof #{counter_size(@sigcount)}",
        :classes => 'highlight_text'
      },
      'x_y_to_next_goal' => {
        :text => "#{@sigcount} signatures\nonly #{counter_size(@sigcount)-@sigcount} more to reach our next goal!",
        :classes => 'highlight_text break'
      },
     'x_y_to_goal' => {
        :text => "#{@sigcount} signatures\nonly #{counter_size(@sigcount)-@sigcount} more to reach our goal!",
        :classes => 'highlight_text break'
     },
     'x_y_to_go_of_z' => {
        :text => "#{@sigcount} signatures\n only #{counter_size(@sigcount)-@sigcount} more to reach our goal of #{counter_size(@sigcount)}!",
        :classes => 'highlight_text break'
     },
     'x_supporters_y_to_next_goal' => {
         :text => "#{@sigcount} supporters have signed\nonly #{counter_size(@sigcount)-@sigcount} more to reach our next goal!",
        :classes => 'highlight_text break'
     },
     'x_supporters_y_to_goal' => {
        :text => "#{@sigcount} supporters have signed\nonly #{counter_size(@sigcount)-@sigcount} more to reach our goal!",
        :classes => 'highlight_text break'
     },
     'x_supporters_help_us' => {
        :text => "#{@sigcount} supporters have signed\nsign now to help us reach our goal of #{counter_size(@sigcount)}!",
        :classes => 'highlight_text break'
     },
     'x_of_y_supporters' => {
        :text => "#{@sigcount} of #{counter_size(@sigcount)} supporters have signed",
        :classes => ''
      }
    }
  end

end
