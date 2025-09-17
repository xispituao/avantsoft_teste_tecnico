require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'associations' do
    it { should belong_to(:frame) }
  end

  describe 'validations' do
    it { should validate_presence_of(:x_axis) }
    it { should validate_presence_of(:y_axis) }
    it { should validate_presence_of(:diameter) }
    it { should validate_presence_of(:frame) }

    it { should validate_numericality_of(:x_axis) }
    it { should validate_numericality_of(:y_axis) }
    it { should validate_numericality_of(:diameter).is_greater_than(0) }
  end

  describe 'custom validations' do
    let(:frame) { create(:frame, x_axis: 1000, y_axis: 1000, width: 100, height: 100) }

    describe 'circle_fits_in_frame' do
      context 'when circle fits inside frame' do
        it 'is valid' do
          circle = build(:circle, x_axis: 1050, y_axis: 1050, diameter: 20, frame: frame)
          expect(circle).to be_valid
        end
      end

      context 'when circle is too big for frame' do
        it 'is invalid' do
          circle = build(:circle, x_axis: 1050, y_axis: 1050, diameter: 120, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo deve caber completamente dentro do quadro')
        end
      end

      context 'when circle touches frame edge' do
        it 'is valid' do
          circle = build(:circle, x_axis: 1010, y_axis: 1010, diameter: 20, frame: frame)
          expect(circle).to be_valid
        end
      end

      context 'when circle exceeds frame boundaries' do
        it 'is invalid when exceeding right edge' do
          circle = build(:circle, x_axis: 1095, y_axis: 1050, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo deve caber completamente dentro do quadro')
        end

        it 'is invalid when exceeding left edge' do
          circle = build(:circle, x_axis: 1005, y_axis: 1050, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo deve caber completamente dentro do quadro')
        end

        it 'is invalid when exceeding top edge' do
          circle = build(:circle, x_axis: 1050, y_axis: 1005, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo deve caber completamente dentro do quadro')
        end

        it 'is invalid when exceeding bottom edge' do
          circle = build(:circle, x_axis: 1050, y_axis: 1095, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo deve caber completamente dentro do quadro')
        end
      end
    end

    describe 'no_circle_overlap' do
      let!(:existing_circle) { create(:circle, x_axis: 1030, y_axis: 1030, diameter: 20, frame: frame) }

      context 'when circles do not touch' do
        it 'is valid' do
          circle = build(:circle, x_axis: 1070, y_axis: 1030, diameter: 20, frame: frame)
          expect(circle).to be_valid
        end
      end

      context 'when circles touch' do
        it 'is invalid' do
          circle = build(:circle, x_axis: 1050, y_axis: 1030, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo não pode tocar outro círculo no mesmo quadro')
        end
      end

      context 'when circles overlap' do
        it 'is invalid' do
          circle = build(:circle, x_axis: 1035, y_axis: 1030, diameter: 20, frame: frame)
          expect(circle).not_to be_valid
          expect(circle.errors[:base]).to include('Círculo não pode tocar outro círculo no mesmo quadro')
        end
      end

      context 'when circles are in different frames' do
        let(:other_frame) { create(:frame, x_axis: 2000, y_axis: 2000, width: 100, height: 100) }

        it 'is valid' do
          circle = build(:circle, x_axis: 2030, y_axis: 2030, diameter: 20, frame: other_frame)
          expect(circle).to be_valid
        end
      end
    end
  end

  describe 'counter cache' do
    let(:frame) { create(:frame) }

    it 'increments frame circles_count when created' do
      expect { create(:circle, frame: frame) }.to change { frame.reload.circles_count }.by(1)
    end

    it 'decrements frame circles_count when destroyed' do
      circle = create(:circle, frame: frame)
      expect { circle.destroy }.to change { frame.reload.circles_count }.by(-1)
    end
  end
end
