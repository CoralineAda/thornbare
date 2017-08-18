require 'rails_helper'

RSpec.describe Resource, type: :model do

  describe ".lose" do

    context "removes high-value cards first" do

      it "with an equal first card" do
        resource_values = [1,1,1,4,5]
        total_resources_lost = 5
        expect(Resource.lose(resource_values, total_resources_lost)[:remove]).to eq([5])
      end

      it "with a higher value first card" do
        resource_values = [1,1,1,4,5]
        total_resources_lost = 4
        expect(Resource.lose(resource_values, total_resources_lost)[:remove]).to eq([4])
      end

    end

    context "removes low-value cards" do

      it "with an equivalent number of low cards" do
        resource_values = [1,1,1,4,5]
        total_resources_lost = 3
        expect(Resource.lose(resource_values, total_resources_lost)[:remove]).to eq([1,1,1])
      end

      it "with a lesser number of low cards and no high cards" do
        resource_values = [1,1,1]
        total_resources_lost = 4
        expect(Resource.lose(resource_values, total_resources_lost)[:remove]).to eq([1,1,1])
      end

    end

    context "makes change" do

      it "with a lesser number of low cards" do
        resource_values = [1,1,4,5]
        total_resources_lost = 3
        expect(Resource.lose(resource_values, total_resources_lost)[:remove]).to eq([4])
        expect(Resource.lose(resource_values, total_resources_lost)[:change]).to eq([1])
      end

    end

  end

end
