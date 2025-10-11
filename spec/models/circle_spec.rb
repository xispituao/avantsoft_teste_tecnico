require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:frame).counter_cache(:circle_count) }
  end

  describe 'validations' do
    describe 'presence validations' do
      it { is_expected.to validate_presence_of(:x_axis) }
      it { is_expected.to validate_presence_of(:y_axis) }
      it { is_expected.to validate_presence_of(:diameter) }
      it { is_expected.to validate_presence_of(:frame) }
    end

    describe 'numericality validations' do
      it { is_expected.to validate_numericality_of(:x_axis) }
      it { is_expected.to validate_numericality_of(:y_axis) }
      it { is_expected.to validate_numericality_of(:diameter).is_greater_than(0) }
    end

    describe 'custom validations' do
      describe '#circle_fits_in_frame' do
        let(:frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }

        context 'when circle fits completely inside frame' do
          it 'is valid' do
            circle = build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 10)
            expect(circle).to be_valid
          end

          context 'at the edges' do
            it 'is valid when touching left edge' do
              circle = build(:circle, frame: frame, x_axis: 5, y_axis: 50, diameter: 10)
              expect(circle).to be_valid
            end

            it 'is valid when touching right edge' do
              circle = build(:circle, frame: frame, x_axis: 95, y_axis: 50, diameter: 10)
              expect(circle).to be_valid
            end

            it 'is valid when touching top edge' do
              circle = build(:circle, frame: frame, x_axis: 50, y_axis: 5, diameter: 10)
              expect(circle).to be_valid
            end

            it 'is valid when touching bottom edge' do
              circle = build(:circle, frame: frame, x_axis: 50, y_axis: 95, diameter: 10)
              expect(circle).to be_valid
            end
          end
        end

        context 'when circle extends beyond frame' do
          it 'is invalid when extending beyond left edge' do
            circle = build(:circle, frame: frame, x_axis: 4, y_axis: 50, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.circle_fits_in_frame'))
            end
          end

          it 'is invalid when extending beyond right edge' do
            circle = build(:circle, frame: frame, x_axis: 96, y_axis: 50, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.circle_fits_in_frame'))
            end
          end

          it 'is invalid when extending beyond top edge' do
            circle = build(:circle, frame: frame, x_axis: 50, y_axis: 4, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.circle_fits_in_frame'))
            end
          end

          it 'is invalid when extending beyond bottom edge' do
            circle = build(:circle, frame: frame, x_axis: 50, y_axis: 96, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.circle_fits_in_frame'))
            end
          end

          it 'is invalid when completely outside frame' do
            circle = build(:circle, frame: frame, x_axis: -50, y_axis: -50, diameter: 10)

            expect(circle).not_to be_valid
          end
        end
      end

      describe '#no_circle_overlap' do
        let(:frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }
        let!(:existing_circle) { create(:circle, frame: frame, x_axis: 25, y_axis: 25, diameter: 10) }

        context 'when circles do not overlap or touch' do
          it 'is valid' do
            circle = build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 10)
            expect(circle).to be_valid
          end

          it 'is valid with minimum safe distance' do
            circle = build(:circle, frame: frame, x_axis: 40, y_axis: 25, diameter: 10)
            expect(circle).to be_valid
          end
        end

        context 'when circles touch' do
          it 'is invalid' do
            circle = build(:circle, frame: frame, x_axis: 35, y_axis: 25, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.no_circle_overlap'))
            end
          end
        end

        context 'when circles overlap' do
          it 'is invalid' do
            circle = build(:circle, frame: frame, x_axis: 30, y_axis: 25, diameter: 10)

            aggregate_failures do
              expect(circle).not_to be_valid
              expect(circle.errors[:base]).to include(I18n.t('models.circle.errors.no_circle_overlap'))
            end
          end

          it 'is invalid when one circle is inside another' do
            circle = build(:circle, frame: frame, x_axis: 25, y_axis: 25, diameter: 2)

            expect(circle).not_to be_valid
          end
        end

        context 'when updating existing circle' do
          it 'does not validate against itself' do
            existing_circle.x_axis = 26
            expect(existing_circle).to be_valid
          end

          it 'validates against other circles' do
            other_circle = create(:circle, frame: frame, x_axis: 75, y_axis: 75, diameter: 10)
            existing_circle.assign_attributes(x_axis: 75, y_axis: 75)

            expect(existing_circle).not_to be_valid
          end
        end

        context 'with different sized circles' do
          it 'considers the sum of radii correctly' do
            circle = build(:circle, frame: frame, x_axis: 45, y_axis: 25, diameter: 20)
            expect(circle).to be_valid
          end
        end
      end
    end
  end

  describe '#radius' do
    let(:circle) { build(:circle, diameter: 20) }

    it 'returns half of diameter' do
      expect(circle.radius).to eq(10)
    end

    it 'memoizes the result' do
      first_call = circle.radius
      second_call = circle.radius

      expect(first_call.object_id).to eq(second_call.object_id)
    end

    it 'handles decimal values' do
      circle.diameter = 15.5
      expect(circle.radius).to eq(7.75)
    end
  end

  describe 'callbacks' do
    let(:frame) { create(:frame, :large) }

    describe 'after_save' do
      it 'updates frame circle positions' do
        expect_any_instance_of(Frame).to receive(:update_circle_positions!).at_least(:once)
        create(:circle, frame: frame)
      end
    end

    describe 'after_destroy' do
      it 'updates frame circle positions' do
        circle = create(:circle, frame: frame)
        expect(frame).to receive(:update_circle_positions!)
        circle.destroy
      end
    end
  end

  describe 'edge cases' do
    let(:frame) { create(:frame, x_axis: 0, y_axis: 0, width: 100, height: 100) }

    context 'with very small diameter' do
      it 'is valid' do
        circle = build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 0.01)
        expect(circle).to be_valid
      end
    end

    context 'with large diameter' do
      it 'validates correctly against frame size' do
        circle = build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 100)
        expect(circle).to be_valid
      end

      it 'is invalid when too large for frame' do
        circle = build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 101)
        expect(circle).not_to be_valid
      end
    end

    context 'with decimal precision' do
      it 'handles decimal coordinates' do
        circle = build(:circle, frame: frame, x_axis: 25.75, y_axis: 30.33, diameter: 5.5)
        expect(circle).to be_valid
      end

      it 'stores decimal values correctly' do
        circle = create(:circle, frame: frame, x_axis: 25.75, y_axis: 30.33, diameter: 5.5)

        aggregate_failures do
          expect(circle.reload.x_axis).to eq(25.75)
          expect(circle.reload.y_axis).to eq(30.33)
          expect(circle.reload.diameter).to eq(5.5)
        end
      end
    end

    context 'with zero diameter' do
      it 'is invalid' do
        circle = build(:circle, frame: frame, diameter: 0)

        aggregate_failures do
          expect(circle).not_to be_valid
          expect(circle.errors[:diameter]).to be_present
        end
      end
    end

    context 'with negative diameter' do
      it 'is invalid' do
        circle = build(:circle, frame: frame, diameter: -5)

        aggregate_failures do
          expect(circle).not_to be_valid
          expect(circle.errors[:diameter]).to be_present
        end
      end
    end

    context 'with coordinates at frame boundaries' do
      it 'handles circles at exact corners' do
        diameter = 10
        radius = 5

        circle = build(:circle, frame: frame, x_axis: radius, y_axis: radius, diameter: diameter)
        expect(circle).to be_valid
      end
    end
  end
end
