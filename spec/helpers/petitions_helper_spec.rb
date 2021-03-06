require 'spec_helper'

describe PetitionsHelper do
  let(:browser) { mock }
  before { helper.stub!(:browser).and_return browser }

  describe '#open_graph_for' do
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:hash) { member.to_hash.to_s }
    let(:config) {{
      facebook: {
        site_name: 'My Super Petitions',
        app_id: 12345
      }
    }}

    before(:each) do
      helper.stub!(:spin!)
      helper.stub!(:social_media_config).and_return config
    end

    subject { helper.open_graph_for(petition, hash) }
    it { should include('og:type' => 'watchdognet:petition') }
    it { should include('og:title' => petition.title) }
    it { should include('og:description' => strip_tags(petition.description)) }
    it "should have an image drawn from the list of possible Facebook images" do
      Rails.configuration.social_media[:facebook][:images].should include subject['og:image']
    end
    it { should include('og:site_name' => 'My Super Petitions') }
    it { should include('fb:app_id' => 12345) }
  end

  describe '#open_graph_for where alternate title exists' do
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:hash) { member.to_hash.to_s}
    let(:alt_title) { create(:petition_title, petition: petition, title_type: PetitionTitle::TitleType::FACEBOOK)}

    context "member hash is nil" do
      subject { helper.open_graph_for(petition, nil) }
      it { should include('og:title' => petition.title)}
    end

    context "member hash does not resolve" do
      subject { helper.open_graph_for(petition, "junk or no longer valid") }
      it { should include('og:title' => petition.title)}
    end

    context "member hash is valid" do
      subject { helper.open_graph_for(petition, hash) }
      it { should include('og:title' => alt_title.title)}
    end
  end

  describe '#choose_form_based_on_browser' do

    context 'for an ie user' do
      before do
        helper.browser.stub!(:ie?).and_return true
        helper.browser.stub!(:user_agent).and_return 'MSIE'
      end

      specify{ helper.choose_form_based_on_browser.should == 'ie_form' }
    end

    context 'for a regular browser user' do
      before do
        helper.browser.stub!(:ie?).and_return false
        helper.browser.stub!(:user_agent).and_return anything
      end

      specify{ helper.choose_form_based_on_browser.should == 'form' }
    end

    context 'for a fake ie user' do
      before do
        helper.browser.stub!(:ie?).and_return true
        helper.browser.stub!(:user_agent).and_return 'chromeframe'
      end

      specify{ helper.choose_form_based_on_browser.should == 'form' }
    end
  end

  describe '#facebook_sharing_option' do

    context 'for an ie7 user' do
      before { browser.stub!(:ie7?).and_return true }
      specify{ helper.facebook_sharing_option.should == 'facebook_popup' }
    end


    context 'for a regular browser user' do
      let(:exp) { 'facebook sharing options' }
      let(:goal) { :referred_member }
      let(:options) { [
        'facebook_popup',
        'facebook_request',
        'facebook_wall'
      ] }

      before { browser.stub!(:ie7?).and_return false }

      it 'should spin for an option' do
        helper.should_receive(:spin!).with(exp, goal, options)
        helper.facebook_sharing_option
      end
    end
  end

  describe '#facebook_button' do

    shared_examples 'facebook button hash' do
      before do
        helper.stub(:facebook_sharing_option).and_return option
      end

      subject { helper.facebook_button }

      it{ should include(button_class: button_class) }
      it{ should include(button_text: button_text) }
    end

    context 'when facebook sharing option is blank' do
      let(:option) { '' }
      let(:button_class) { 'fb_popup_btn' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_share"' do
      let(:option) { 'facebook_share' }
      let(:button_class) { 'fb_share' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_popup"' do
      let(:option) { 'facebook_popup' }
      let(:button_class) { 'fb_popup_btn' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_wall"' do

      let(:option) { 'facebook_wall' }
      let(:button_class) { 'fb_widget_btn' }
      let(:button_text) { 'Share with your friends' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_request"' do
      let(:option) { 'facebook_request' }
      let(:button_class) { 'fb_request_btn' }
      let(:button_text) { 'Send request to friends' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_request" and sub-experiment is "facebook_autofill_request"' do
      let(:option) { 'facebook_autofill_request' }
      let(:button_class) { 'fb_autofill_request_btn' }
      let(:button_text) { 'Send request to friends' }

      it_behaves_like 'facebook button hash'
    end
  end

  describe '#after_share_view' do
    shared_examples 'thanks_for_signing' do
      specify { helper.after_share_view.should == 'thanks_for_signing' }
    end

    context 'for an ie user' do
      before { browser.stub!(:ie?).and_return true }
      it_behaves_like 'thanks_for_signing'
    end

    context 'for a regular browser user' do
      let(:exp) { 'after share view 3' }
      let(:goal) { :share }
      let(:options) { [
        "thanks_for_signing",
        "button_is_most_effective_tool",
        "button_is_most_effective_tool_with_thanks",
        "tell_two_friends",
        "tell_two_friends_with_thanks",
        "signatures_stop_signatures_multiply",
        "signatures_stop_signatures_multiply_with_thanks",
        "mandela-time_ripe_to_do_right",
        "mandela-time_ripe_to_do_right-color",
        "teresa-stone_creates_ripples-color",
        "teresa-stone_creates_ripples",
        "gandhi-shake_the_world",
        "king-do_what_is_right",
        "king-do_what_is_right-color",
        "melanie_1",
        "melanie_2",
        "most_people_will_share_will_you",
        "most_people_will_share_will_you_with_thanks",
        "over_x_shares_and_counting-with_counter",
        "if_facebook_is_slow_try_again_later",
        "tell_two_friends-sandwich-grey",
        "almost_there_one_thing_to_do",
        "almost_there_one_thing_to_do_with_thanks",
        "checklist",
        "demand_progress_facebook_pictures",
        "demand_progress_facebook_pictures_with_thanks",
        "wow_most_shared_petition_ever",
        "hey_youre_not_done_yet",
        "hey_you_youre_not_done_yet",
        "thanks_youre_not_done_yet",
        "name_youre_not_done_yet",
        "kitten_sad",
        "kitten_treat",
        "puppy_sad",
        "puppy_treat",
        "ferret_treat",
        "fb_rotator-most_people_will_share",
        "no_thanks_vs_share"
      ]
   }

      before { browser.stub!(:ie?).and_return false }

      it 'should spin for an option' do
        helper.should_receive(:spin!).with(exp, goal, options)
        helper.after_share_view
      end
    end
  end

  describe '#counter_size' do
    it 'should be greater than the number of signatures' do
      helper.counter_size(0).should == 5
      helper.counter_size(5).should == 10
      helper.counter_size(100000).should == 1000000
    end
  end

  describe '#progress_option' do
    let(:exp) { 'test different messaging on progress bar' }
    let(:goal) { :signature }
    let(:options) { ['foo', 'bar'] }
    let(:config) { { 'foo' => {}, 'bar' => {} } }

    before { helper.stub!(:progress_options_config).and_return config }

    it 'should spin for an option' do
      helper.should_receive(:spin!).with(exp, goal, options)
      helper.progress_option
    end
  end

  describe '#progress' do
    let(:config) {{
      'foo' => { :text => 'Sign it dude!', :classes => 'highlight' },
      'bar' => { :text => 'Please, sign!', :classes => 'downfade' }
    }}

    before { helper.stub!(:progress_options_config).and_return config }

    context 'for successful spin' do
      before { helper.stub!(:progress_option).and_return 'bar' }
      specify { helper.progress[:text].should == 'Please, sign!' }
      specify { helper.progress[:classes].should == 'downfade' }
    end

    context 'for failed spin' do
      before { helper.stub!(:progress_option).and_return false }
      specify { helper.progress[:text].should be_empty }
      specify { helper.progress[:classes].should be_empty }
    end
  end
end
