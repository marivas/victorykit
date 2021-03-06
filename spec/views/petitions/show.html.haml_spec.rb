require "spec_helper"

describe "petitions/show.html.haml" do
  
  let(:petition) { create(:petition) }
  let(:signature) { create(:signature) }
  let(:user) { create(:user) }
  let(:member) { create(:member) }
  
  before do
    view.stub(:current_user) { user }
    view.stub(:petition_url) { "url_to_the_petition" }    
    social_media_config[:facebook][:app_id] = 321

    assign :petition, petition
    assign :signature, signature
    assign :sigcount, 1

    view.stub(:spin!) { false }
  end

  it "doesn't fail when rendering" do
    render
  end

end
