# frozen_string_literal: true

require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/event_attendees", type: :request do
  let(:event_attendee) { create :event_attendee }

  let(:user) { nil }

  before(:each) do
    sign_in user if user
  end

  describe "GET /index" do
    subject(:get_index) { get event_attendees_url }

    context "when user is logged in" do
      let!(:event_attendee) { create_list :event_attendee, 2 }
      let(:user) { event_attendee[0].profile.user }

      it "renders a successful response" do
        get_index
        expect(response.body).to include(event_attendee[0].profile_id.to_s)
      end

      it "don't render other users records" do
        get_index
        expect(response.body).not_to include(event_attendee[1].profile_id.to_s)
      end
    end
  end

  describe "GET /show" do
    subject(:get_show) { get event_attendee_url(event_attendee) }

    it "renders a successful response" do
      get_show
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    subject(:get_new) { get new_event_attendee_url }

    include_examples "redirect to sign in"

    context "when user is logged in" do
      let(:user) { create :user }

      it "renders a successful response" do
        get_new
        expect(response).to be_successful
      end
    end
  end

  describe "GET /edit" do
    subject(:get_edit) { get edit_event_attendee_url(event_attendee) }

    include_examples "redirect to sign in"

    context "when user does not match profile" do
      let(:user) { create :user }

      include_examples "unauthorized access"
    end

    context "when user matches profile" do
      let(:user) { event_attendee.profile.user }

      it "render a successful response" do
        get_edit
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    subject(:post_create) { post event_attendees_url, params: { event_attendee: attributes } }

    context "with valid parameters" do
      let(:profile) { create(:profile) }
      let(:attributes) do
        {
          profile_id: profile.id,
          event_id: create(:event).id
        }
      end

      include_examples "redirect to sign in"

      context "when user does not match profile" do
        let(:user) { create :user }

        include_examples "unauthorized access"
      end

      context "when user matches profile" do
        let(:user) { profile.user }

        it "creates a new EventAttendee" do
          expect { post_create }.to change(EventAttendee, :count).by(1)
        end

        it "redirects to the created event_attendee" do
          post_create
          expect(response).to redirect_to(event_attendee_url(EventAttendee.last))
        end
      end
    end

    context "with invalid parameters and valid user" do
      let(:attributes) { { profile_id: profile.id } }
      let(:profile) { create(:profile) }
      let(:user) { profile.user }

      it "does not create a new EventAttendee" do
        expect { post_create }.to change(EventAttendee, :count).by(0)
      end

      it "returns an unprocessable entity code" do
        post_create
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PATCH /update" do
    subject(:patch_update) { patch event_attendee_url(event_attendee), params: { event_attendee: attributes } }

    let(:event_attendee) { create :event_attendee }

    context "with valid parameters" do
      let(:attributes) do
        { event_id: create(:event, name: "StrangeLoop").id }
      end

      include_examples "redirect to sign in"

      context "when user does not match profile" do
        let(:user) { create :user }

        include_examples "unauthorized access"
      end

      context "when user matches profile" do
        let(:user) { event_attendee.profile.user }

        it "updates the requested event_attendee" do
          patch_update
          event_attendee.reload
          expect(event_attendee.event.name).to eq "StrangeLoop"
        end

        it "redirects to the event_attendee" do
          patch_update
          expect(response).to redirect_to(event_attendee_url(event_attendee))
        end
      end
    end

    context "with invalid parameters and valid user" do
      let(:attributes) { { event_id: nil } }
      let(:user) { event_attendee.profile.user }

      it "returns an unprocessable entity code" do
        patch_update
        expect(response.status).to eq(422)
      end

      it "updates the event name" do
        patch_update
        expect(event_attendee.reload.event.name).to eq "RubyConf"
      end
    end
  end

  describe "DELETE /destroy" do
    subject(:delete_destroy) { delete event_attendee_url(event_attendee) }

    let!(:event_attendee) { create :event_attendee }

    include_examples "redirect to sign in"

    context "when unrelated user" do
      let(:user) { create :user }

      include_examples "unauthorized access"

      it "does not allow folks to delete others event attendance" do
        delete_destroy
        expect(event_attendee.id).to eq event_attendee.reload.id
      end
    end

    context "when user matches profile" do
      let(:user) { event_attendee.profile.user }

      it "destroys the requested event_attendee" do
        expect { delete_destroy }.to change(EventAttendee, :count).by(-1)
      end

      it "redirects to the event_attendees list" do
        delete_destroy
        expect(response).to redirect_to(event_attendees_url)
      end
    end
  end
end
