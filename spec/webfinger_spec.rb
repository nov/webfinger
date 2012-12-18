require 'spec_helper'

describe WebFinger do
  describe '#cache' do
    subject { WebFinger.cache }

    context 'as default' do
      it { should be_nil }
    end

    context 'when specified' do
      let(:cacher) { 'Rails.cache or something' }
      before { WebFinger.cache = cacher }
      it { should == cacher }
    end
  end

  describe '#logger' do
    subject { WebFinger.logger }

    context 'as default' do
      it { should be_instance_of Logger }
    end

    context 'when specified' do
      let(:logger) { 'Rails.logger or something' }
      before { WebFinger.logger = logger }
      it { should == logger }
    end
  end

  describe '#debugging?' do
    subject { WebFinger.debugging? }

    context 'as default' do
      it { should be_false }
    end

    context 'when debugging' do
      before { WebFinger.debug! }
      it { should be_true }

      context 'when debugging mode canceled' do
        before { WebFinger.debugging = false }
        it { should be_false }
      end
    end
  end

  describe '#url_builder' do
    subject { WebFinger.url_builder }

    context 'as default' do
      it { should == URI::HTTPS }
    end

    context 'when specified' do
      let(:url_builder) { 'URI::HTTP or something' }
      before { WebFinger.url_builder = url_builder }
      it { should == url_builder }
    end
  end

  describe '#http_client' do
    subject { WebFinger.http_client }

    describe '#request_filter' do
      subject { WebFinger.http_client.request_filter.collect(&:class) }

      context 'as default' do
        it { should_not include WebFinger::Debugger::RequestFilter }
      end

      context 'when debugging' do
        before { WebFinger.debug! }
        it { should include WebFinger::Debugger::RequestFilter }
      end
    end
  end
end