require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:circles).dependent(:restrict_with_error) }
    it { is_expected.to accept_nested_attributes_for(:circles).allow_destroy(true) }
  end

  describe 'validations' do
    describe 'presence validations' do
      it { is_expected.to validate_presence_of(:x_axis) }
      it { is_expected.to validate_presence_of(:y_axis) }
      it { is_expected.to validate_presence_of(:width) }
      it { is_expected.to validate_presence_of(:height) }
    end

    describe 'numericality validations' do
      it { is_expected.to validate_numericality_of(:x_axis) }
      it { is_expected.to validate_numericality_of(:y_axis) }
      it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
    end

    describe 'custom validations' do
      describe '#no_frame_overlap' do
        let!(:reference_frame) { create(:frame, :medium, x_axis: 0, y_axis: 0) }

        context 'with frames that do not overlap or touch' do
          subject { frame_separated_from(reference_frame, gap: 10, direction: :diagonal) }
          it_behaves_like 'valid frame'

          it 'is valid when frames are vertically separated' do
            frame = frame_separated_from(reference_frame, gap: 10, direction: :bottom)
            expect(frame).to be_valid
          end

          it 'is valid when frames are horizontally separated' do
            frame = frame_separated_from(reference_frame, gap: 10, direction: :right)
            expect(frame).to be_valid
          end
        end

        context 'with frames that overlap' do
          context 'when frames overlap completely' do
            subject do
              build(:frame,
                x_axis: reference_frame.x_axis,
                y_axis: reference_frame.y_axis,
                width: reference_frame.width,
                height: reference_frame.height
              )
            end

            it_behaves_like 'invalid with overlap error'
          end

          context 'when frames overlap partially' do
            subject { frame_at(x: 25, y: 25, width: 50, height: 50) }
            it_behaves_like 'invalid with overlap error'
          end

          context 'when one frame is inside another' do
            subject { frame_at(x: 10, y: 10, width: 20, height: 20) }
            it_behaves_like 'invalid with overlap error'
          end
        end

        context 'with frames that touch on edges' do
          context 'when touching on right edge' do
            subject { frame_touching_right(reference_frame) }
            it_behaves_like 'invalid with overlap error'
          end

          context 'when touching on bottom edge' do
            subject { frame_touching_bottom(reference_frame) }
            it_behaves_like 'invalid with overlap error'
          end

          context 'when touching on left edge' do
            subject do
              build(:frame,
                x_axis: reference_frame.x_axis - 50,
                y_axis: reference_frame.y_axis,
                width: 50,
                height: 50
              )
            end

            it_behaves_like 'invalid with overlap error'
          end

          context 'when touching on top edge' do
            subject do
              build(:frame,
                x_axis: reference_frame.x_axis,
                y_axis: reference_frame.y_axis - 50,
                width: 50,
                height: 50
              )
            end

            it_behaves_like 'invalid with overlap error'
          end
        end

        context 'when updating an existing frame' do
          it 'does not validate against itself' do
            reference_frame.x_axis = 5

            expect(reference_frame).to be_valid
          end

          it 'validates against other frames' do
            other_frame = create(:frame, x_axis: 100, y_axis: 100, width: 50, height: 50)

            aggregate_failures do
              reference_frame.assign_attributes(x_axis: 100, y_axis: 100)
              expect(reference_frame).not_to be_valid
              expect(reference_frame.errors[:base])
                .to include(I18n.t('models.frame.errors.no_frame_overlap'))
            end
          end
        end
      end
    end
  end

  describe '#update_circle_positions!' do
    let(:frame) { create(:frame, :large) }

    context 'when frame has no circles' do
      it 'resets all position fields to nil' do
        frame.update_circle_positions!

        aggregate_failures do
          expect(frame.highest_circle_position).to be_nil
          expect(frame.lowest_circle_position).to be_nil
          expect(frame.leftmost_circle_position).to be_nil
          expect(frame.rightmost_circle_position).to be_nil
        end
      end
    end

    context 'when frame has circles' do
      before do
        create(:circle, frame: frame, x_axis: 10, y_axis: 10)
        create(:circle, frame: frame, x_axis: 90, y_axis: 90)
        create(:circle, frame: frame, x_axis: 50, y_axis: 50)
      end

      it 'updates highest_circle_position to minimum y_axis' do
        frame.update_circle_positions!
        expect(frame.highest_circle_position).to eq(10)
      end

      it 'updates lowest_circle_position to maximum y_axis' do
        frame.update_circle_positions!
        expect(frame.lowest_circle_position).to eq(90)
      end

      it 'updates leftmost_circle_position to minimum x_axis' do
        frame.update_circle_positions!
        expect(frame.leftmost_circle_position).to eq(10)
      end

      it 'updates rightmost_circle_position to maximum x_axis' do
        frame.update_circle_positions!
        expect(frame.rightmost_circle_position).to eq(90)
      end

      it 'updates all positions in a single query' do
        expect(frame).to receive(:update_columns).once
        frame.update_circle_positions!
      end
    end
  end

  describe 'GeometryHelper integration' do
    describe '.rectangles_overlap_or_touch?' do
      subject { GeometryHelper.rectangles_overlap_or_touch?(frame1, frame2) }

      let(:frame1) { build(:frame, x_axis: 0, y_axis: 0, width: 50, height: 50) }

      context 'when rectangles do not overlap or touch' do
        context 'with completely separate rectangles' do
          let(:frame2) { frame_at(x: 100, y: 100) }
          it { is_expected.to be false }
        end

        context 'with a gap between rectangles' do
          let(:frame2) { frame_at(x: 60, y: 0) }
          it { is_expected.to be false }
        end
      end

      context 'when rectangles touch' do
        context 'on right edge' do
          let(:frame2) { frame_at(x: 50, y: 0) }
          it { is_expected.to be true }
        end

        context 'on bottom edge' do
          let(:frame2) { frame_at(x: 0, y: 50) }
          it { is_expected.to be true }
        end

        context 'at a corner' do
          let(:frame2) { frame_at(x: 50, y: 50) }
          it { is_expected.to be true }
        end
      end

      context 'when rectangles overlap' do
        context 'partially' do
          let(:frame2) { frame_at(x: 25, y: 25) }
          it { is_expected.to be true }
        end

        context 'completely' do
          let(:frame2) { frame_at(x: 0, y: 0) }
          it { is_expected.to be true }
        end

        context 'with one inside another' do
          let(:frame2) { frame_at(x: 10, y: 10, width: 20, height: 20) }
          it { is_expected.to be true }
        end
      end
    end
  end

  describe 'destruction' do
    context 'when frame has no circles' do
      let!(:frame) { create(:frame, x_axis: 0, y_axis: 0, width: 50, height: 50) }

      it 'can be destroyed' do
        expect { frame.destroy }.to change(Frame, :count).by(-1)
      end

      it 'returns truthy value' do
        expect(frame.destroy).to be_truthy
      end
    end

    context 'when frame has circles' do
      let!(:frame) { create(:frame, :with_circles, circles_count: 2) }

      it 'cannot be destroyed' do
        expect { frame.destroy }.not_to change(Frame, :count)
      end

      it 'returns falsey value' do
        expect(frame.destroy).to be_falsey
      end

      it 'adds error to the frame' do
        frame.destroy
        expect(frame.errors).not_to be_empty
      end

      it 'keeps circles in database' do
        expect { frame.destroy }.not_to change(Circle, :count)
      end
    end
  end

  describe 'nested attributes for circles' do
    describe 'creating circles with frame' do
      let(:frame_attributes) do
        {
          x_axis: 0,
          y_axis: 0,
          width: 100,
          height: 100,
          circles_attributes: [
            { x_axis: 25, y_axis: 25, diameter: 10 },
            { x_axis: 75, y_axis: 75, diameter: 10 }
          ]
        }
      end

      it 'creates circles when creating a frame' do
        expect { Frame.create!(frame_attributes) }.to change(Circle, :count).by(2)
      end

      it 'associates circles with the frame' do
        frame = Frame.create!(frame_attributes)
        expect(frame.circles.count).to eq(2)
      end
    end

    describe 'updating circles' do
      let(:frame) { create(:frame, :large) }
      let!(:circle) { create(:circle, frame: frame, x_axis: 25, y_axis: 25, diameter: 10) }

      it 'updates circle attributes' do
        expect {
          frame.update(circles_attributes: [ { id: circle.id, x_axis: 30 } ])
        }.to change { circle.reload.x_axis }.from(25).to(30)
      end

      it 'does not change circle count' do
        expect {
          frame.update(circles_attributes: [ { id: circle.id, x_axis: 30 } ])
        }.not_to change(Circle, :count)
      end
    end

    describe 'destroying circles' do
      let(:frame) { create(:frame, :large) }
      let!(:circle) { create(:circle, frame: frame) }

      it 'destroys circles when _destroy is true' do
        expect {
          frame.update(circles_attributes: [ { id: circle.id, _destroy: true } ])
        }.to change(Circle, :count).by(-1)
      end
    end

    describe 'rejecting blank circles' do
      let(:frame_attributes) do
        {
          x_axis: 0,
          y_axis: 0,
          width: 100,
          height: 100,
          circles_attributes: [ { x_axis: nil, y_axis: nil, diameter: nil } ]
        }
      end

      it 'does not create blank circles' do
        expect { Frame.create!(frame_attributes) }.not_to change(Circle, :count)
      end
    end
  end

  describe 'circle counter cache' do
    let(:frame) { create(:frame, :large) }

    it 'starts with zero circles' do
      expect(frame.circle_count).to eq(0)
    end

    describe 'when adding circles' do
      it 'increments counter' do
        expect {
          create(:circle, frame: frame)
        }.to change { frame.reload.circle_count }.from(0).to(1)
      end

      it 'increments for multiple circles' do
        expect {
          create(:circle, frame: frame, x_axis: frame.x_axis + 10, y_axis: frame.y_axis + 10)
          create(:circle, frame: frame, x_axis: frame.x_axis + 30, y_axis: frame.y_axis + 10)
          create(:circle, frame: frame, x_axis: frame.x_axis + 50, y_axis: frame.y_axis + 10)
        }.to change { frame.reload.circle_count }.from(0).to(3)
      end
    end

    describe 'when removing circles' do
      let!(:circle) { create(:circle, frame: frame) }

      it 'decrements counter' do
        expect {
          circle.destroy
        }.to change { frame.reload.circle_count }.from(1).to(0)
      end
    end

    describe 'with multiple operations' do
      it 'maintains accurate count' do
        create(:circle, frame: frame, x_axis: frame.x_axis + 10, y_axis: frame.y_axis + 10)
        create(:circle, frame: frame, x_axis: frame.x_axis + 30, y_axis: frame.y_axis + 10)
        create(:circle, frame: frame, x_axis: frame.x_axis + 50, y_axis: frame.y_axis + 10)
        create(:circle, frame: frame, x_axis: frame.x_axis + 70, y_axis: frame.y_axis + 10)
        create(:circle, frame: frame, x_axis: frame.x_axis + 10, y_axis: frame.y_axis + 30)
        expect(frame.reload.circle_count).to eq(5)

        frame.circles.first.destroy
        expect(frame.reload.circle_count).to eq(4)

        create(:circle, frame: frame, x_axis: frame.x_axis + 30, y_axis: frame.y_axis + 30)
        expect(frame.reload.circle_count).to eq(5)
      end
    end
  end

  describe 'circle position updates via callbacks' do
    let(:frame) { create(:frame, :large) }

    context 'when creating a circle' do
      it 'updates frame circle positions' do
        circle = create(:circle, frame: frame, x_axis: 25, y_axis: 30)

        aggregate_failures do
          expect(frame.reload.highest_circle_position).to eq(30)
          expect(frame.reload.lowest_circle_position).to eq(30)
          expect(frame.reload.leftmost_circle_position).to eq(25)
          expect(frame.reload.rightmost_circle_position).to eq(25)
        end
      end

      it 'updates positions with multiple circles' do
        create(:circle, frame: frame, x_axis: 10, y_axis: 10)
        create(:circle, frame: frame, x_axis: 90, y_axis: 90)

        aggregate_failures do
          expect(frame.reload.highest_circle_position).to eq(10)
          expect(frame.reload.lowest_circle_position).to eq(90)
          expect(frame.reload.leftmost_circle_position).to eq(10)
          expect(frame.reload.rightmost_circle_position).to eq(90)
        end
      end
    end

    context 'when updating a circle position' do
      let!(:circle) { create(:circle, frame: frame, x_axis: 50, y_axis: 50) }

      it 'recalculates frame positions' do
        circle.update(x_axis: 80, y_axis: 80)

        aggregate_failures do
          expect(frame.reload.highest_circle_position).to eq(80)
          expect(frame.reload.rightmost_circle_position).to eq(80)
        end
      end
    end

    context 'when destroying a circle' do
      let!(:circle1) { create(:circle, frame: frame, x_axis: 10, y_axis: 10) }
      let!(:circle2) { create(:circle, frame: frame, x_axis: 90, y_axis: 90) }

      it 'recalculates frame positions' do
        circle2.destroy

        aggregate_failures do
          expect(frame.reload.highest_circle_position).to eq(10)
          expect(frame.reload.lowest_circle_position).to eq(10)
          expect(frame.reload.leftmost_circle_position).to eq(10)
          expect(frame.reload.rightmost_circle_position).to eq(10)
        end
      end

      it 'resets positions when last circle is removed' do
        circle1.destroy
        circle2.destroy

        aggregate_failures do
          expect(frame.reload.highest_circle_position).to be_nil
          expect(frame.reload.lowest_circle_position).to be_nil
          expect(frame.reload.leftmost_circle_position).to be_nil
          expect(frame.reload.rightmost_circle_position).to be_nil
        end
      end
    end
  end

  describe 'edge cases' do
    context 'with decimal precision' do
      subject { build(:frame, x_axis: 10.75, y_axis: 20.33, width: 50.99, height: 75.11) }
      it { is_expected.to be_valid }

      it 'stores decimal values correctly' do
        subject.save!

        aggregate_failures do
          expect(subject.reload.x_axis).to eq(10.75)
          expect(subject.reload.y_axis).to eq(20.33)
          expect(subject.reload.width).to eq(50.99)
          expect(subject.reload.height).to eq(75.11)
        end
      end

      context 'with very small dimensions' do
        subject { build(:frame, width: 0.01, height: 0.01) }
        it { is_expected.to be_valid }
      end
    end

    context 'with negative coordinates' do
      it 'accepts negative x_axis' do
        frame = build(:frame, x_axis: -100, y_axis: 0, width: 50, height: 50)
        expect(frame).to be_valid
      end

      it 'accepts negative y_axis' do
        frame = build(:frame, x_axis: 0, y_axis: -100, width: 50, height: 50)
        expect(frame).to be_valid
      end

      it 'accepts both negative coordinates' do
        frame = build(:frame, x_axis: -100, y_axis: -100, width: 50, height: 50)
        expect(frame).to be_valid
      end
    end

    context 'with zero or negative dimensions' do
      it 'is invalid with zero width' do
        frame = build(:frame, width: 0)

        aggregate_failures do
          expect(frame).not_to be_valid
          expect(frame.errors[:width]).to be_present
        end
      end

      it 'is invalid with zero height' do
        frame = build(:frame, height: 0)

        aggregate_failures do
          expect(frame).not_to be_valid
          expect(frame.errors[:height]).to be_present
        end
      end

      it 'is invalid with negative width' do
        frame = build(:frame, width: -10)

        aggregate_failures do
          expect(frame).not_to be_valid
          expect(frame.errors[:width]).to be_present
        end
      end

      it 'is invalid with negative height' do
        frame = build(:frame, height: -10)

        aggregate_failures do
          expect(frame).not_to be_valid
          expect(frame.errors[:height]).to be_present
        end
      end
    end

    context 'with very large values' do
      subject do
        build(:frame,
          x_axis: 999999.99,
          y_axis: 999999.99,
          width: 999999.99,
          height: 999999.99
        )
      end

      it { is_expected.to be_valid }
    end
  end
end
