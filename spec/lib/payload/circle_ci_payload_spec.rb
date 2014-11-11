require 'spec_helper'

describe CircleCiPayload do

  let(:status_content) { load_fixture('circleci_examples', fixture_file) }
  let(:payload) { CircleCiPayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:fixture_file) { "success.json" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'and status is pending' do
      let(:fixture_file) { "pending.json" }
      let(:content) { {'status' => 'running'} }

      it 'should be marked as unprocessable' do
        expect(payload.content_ready?(content)).to be false
      end
    end

    context 'and content is valid' do
      let(:expected_content) { double(:content, key?: false) }
      before do
        allow(JSON).to receive(:parse).and_return(expected_content)
      end

      it{ is_expected.to eq([expected_content]) }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        expect(payload.processable).to be false
      end

      context "bad XML data" do
        let(:wrong_status_content) { "some non xml content" }
        it "should log errors" do
          expect(payload).to receive("log_error")
          payload.status_content = wrong_status_content
        end
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload contains a successful build status' do
      it { is_expected.to be true }
    end

    context 'the payload contains a failure build status' do
      let(:fixture_file) { "failure.json" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(content) }

    context 'outcome is empty' do
      let(:fixture_file) { "outcome_is_empty.json" }
      it { is_expected.to be false }
    end

    context 'the build has not finished' do
      let(:fixture_file) { "pending.json" }
      it { is_expected.to be false }
    end

    context 'the build has finished' do
      it { is_expected.to be true }
    end
  end

  describe '#parse_url' do
    subject { payload.parse_url(content) }

    it { is_expected.to eq('https://circleci.com/gh/auser/project/172') }
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { is_expected.to eq(172) }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content).round }
    it { is_expected.to eq(Time.utc(2013, 10, 15, 8, 47, 30)) }
  end

end
