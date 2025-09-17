require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it { should have_many(:circles) }
  end

  describe 'validations' do
    it { should validate_presence_of(:x_axis) }
    it { should validate_presence_of(:y_axis) }
    it { should validate_presence_of(:width) }
    it { should validate_presence_of(:height) }
    it { should validate_presence_of(:total_circles) }

    it { should validate_numericality_of(:x_axis) }
    it { should validate_numericality_of(:y_axis) }
    it { should validate_numericality_of(:width).is_greater_than(0) }
    it { should validate_numericality_of(:height).is_greater_than(0) }
    it { should validate_numericality_of(:total_circles).is_greater_than_or_equal_to(0) }
  end

  describe 'custom validations' do
    describe 'no_frame_overlap' do
      let!(:existing_frame) { create(:frame, x_axis: 1000, y_axis: 1000, width: 100, height: 100) }

      context 'when frames do not overlap' do
        it 'is valid' do
          frame = build(:frame, x_axis: 1200, y_axis: 1000, width: 100, height: 100)
          expect(frame).to be_valid
        end
      end

      context 'when frames touch' do
        it 'is invalid' do
          frame = build(:frame, x_axis: 1100, y_axis: 1000, width: 100, height: 100)
          expect(frame).not_to be_valid
          expect(frame.errors[:base]).to include('Quadro não pode tocar outro quadro')
        end
      end

      context 'when frames overlap' do
        it 'is invalid' do
          frame = build(:frame, x_axis: 1050, y_axis: 1000, width: 100, height: 100)
          expect(frame).not_to be_valid
          expect(frame.errors[:base]).to include('Quadro não pode tocar outro quadro')
        end
      end
    end
  end

  describe 'counter cache' do
    let(:frame) { create(:frame, x_axis: 1000, y_axis: 1000, width: 100, height: 100) }

    it 'updates circles_count when circle is created' do
      expect { create(:circle, frame: frame, x_axis: 1050, y_axis: 1050, diameter: 20) }.to change { frame.reload.circles_count }.by(1)
    end

    it 'updates circles_count when circle is destroyed' do
      circle = create(:circle, frame: frame, x_axis: 1050, y_axis: 1050, diameter: 20)
      expect { circle.destroy }.to change { frame.reload.circles_count }.by(-1)
    end
  end
end
