require 'rails_helper'

RSpec.describe GeometryHelper do
  describe '.rectangles_overlap_or_touch?' do
    subject { described_class.rectangles_overlap_or_touch?(frame1, frame2) }

    let(:frame1) { build(:frame, x_axis: 0, y_axis: 0, width: 50, height: 50) }

    context 'when rectangles do not overlap or touch' do
      let(:frame2) { build(:frame, x_axis: 100, y_axis: 100, width: 50, height: 50) }
      it { is_expected.to be false }

      context 'with horizontal separation' do
        let(:frame2) { build(:frame, x_axis: 60, y_axis: 0, width: 50, height: 50) }
        it { is_expected.to be false }
      end

      context 'with vertical separation' do
        let(:frame2) { build(:frame, x_axis: 0, y_axis: 60, width: 50, height: 50) }
        it { is_expected.to be false }
      end
    end

    context 'when rectangles touch' do
      context 'on right edge' do
        let(:frame2) { build(:frame, x_axis: 50, y_axis: 0, width: 50, height: 50) }
        it { is_expected.to be true }
      end

      context 'on bottom edge' do
        let(:frame2) { build(:frame, x_axis: 0, y_axis: 50, width: 50, height: 50) }
        it { is_expected.to be true }
      end

      context 'on corner' do
        let(:frame2) { build(:frame, x_axis: 50, y_axis: 50, width: 50, height: 50) }
        it { is_expected.to be true }
      end
    end

    context 'when rectangles overlap' do
      let(:frame2) { build(:frame, x_axis: 25, y_axis: 25, width: 50, height: 50) }
      it { is_expected.to be true }
    end
  end

  describe '.euclidean_distance' do
    subject { described_class.euclidean_distance(x1, y1, x2, y2) }

    context 'with same point' do
      let(:x1) { 0 }
      let(:y1) { 0 }
      let(:x2) { 0 }
      let(:y2) { 0 }

      it { is_expected.to eq(0) }
    end

    context 'with horizontal distance' do
      let(:x1) { 0 }
      let(:y1) { 0 }
      let(:x2) { 10 }
      let(:y2) { 0 }

      it { is_expected.to eq(10) }
    end

    context 'with vertical distance' do
      let(:x1) { 0 }
      let(:y1) { 0 }
      let(:x2) { 0 }
      let(:y2) { 10 }

      it { is_expected.to eq(10) }
    end

    context 'with diagonal distance' do
      let(:x1) { 0 }
      let(:y1) { 0 }
      let(:x2) { 3 }
      let(:y2) { 4 }

      it { is_expected.to eq(5) } # 3-4-5 triangle
    end
  end

  describe '.circles_overlap_or_touch?' do
    subject { described_class.circles_overlap_or_touch?(circle1, circle2) }

    let(:frame) { build(:frame, :large) }
    let(:circle1) { build(:circle, frame: frame, x_axis: 25, y_axis: 25, diameter: 10) }

    context 'when circles do not overlap or touch' do
      let(:circle2) { build(:circle, frame: frame, x_axis: 50, y_axis: 50, diameter: 10) }
      it { is_expected.to be false }
    end

    context 'when circles touch exactly' do
      let(:circle2) { build(:circle, frame: frame, x_axis: 35, y_axis: 25, diameter: 10) }
      it { is_expected.to be true }
    end

    context 'when circles overlap' do
      let(:circle2) { build(:circle, frame: frame, x_axis: 30, y_axis: 25, diameter: 10) }
      it { is_expected.to be true }
    end

    context 'with different sized circles' do
      let(:circle1) { build(:circle, frame: frame, x_axis: 25, y_axis: 25, diameter: 20) }
      let(:circle2) { build(:circle, frame: frame, x_axis: 50, y_axis: 25, diameter: 10) }

      it 'considers the sum of radii' do
        expect(subject).to be false
      end
    end
  end
end
