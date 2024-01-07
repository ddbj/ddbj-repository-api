require 'rails_helper'

RSpec.describe TradValidator, type: :model do
  def create_seq(request, name: 'foo.fasta', content: <<~SEQ)
    >CLN01
    ggacaggctgccgcaggagccaggccgggagcaggaagaggcttcgggggagccggagaa
    ctgggccagatgcgcttcgtgggcgaagcctgaggaaaaagagagtgaggcaggagaatc
    gcttgaaccccggaggcggaaccgcactccagcctgggcgacagagtgagactta
    //
    >CLN02
    ctcacacagatgcgcgcacaccagtggttgtaacagaagcctgaggtgcgctcgtggtca
    gaagagggcatgcgcttcagtcgtgggcgaagcctgaggaaaaaatagtcattcatataa
    atttgaacacacctgctgtggctgtaactctgagatgtgctaaataaaccctctt
    //
  SEQ

    create(:obj, request:, _id: 'Sequence', file: uploaded_file(name:, content:))
  end

  def create_ann(request, name: 'foo.ann', content: <<~ANN)
    COMMON	SUBMITTER		contact	Alice Liddell
    			email	alice@example.com
    			institute	Wonderland Inc.
  ANN

    create(:obj, request:, _id: 'Annotation', file: uploaded_file(name:, content:))
  end

  let(:request) { create(:request, db: 'Trad') }

  example 'ok' do
    seq = create_seq(request)
    ann = create_ann(request)

    TradValidator.new.validate request
    [seq, ann].each &:reload

    expect(seq).to have_attributes(
      validity:           'valid',
      validation_details: nil
    )

    expect(ann).to have_attributes(
      validity:           'valid',
      validation_details: nil
    )
  end

  describe 'ext' do
    example do
      seq = create_seq(request, name: 'foo.bar')
      ann = create_ann(request, name: 'foo.baz')

      TradValidator.new.validate request
      [seq, ann].each &:reload

      expect(seq).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'The extension should be one of the following: .fasta, .seq.fa, .fa, .fna, .seq'
        ]
      )

      expect(ann).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'The extension should be one of the following: .ann, .annt.tsv, .ann.txt'
        ]
      )
    end
  end

  describe 'pairwise' do
    example 'not paired' do
      seq = create_seq(request, name: 'foo.fasta')
      ann = create_ann(request, name: 'bar.ann')

      TradValidator.new.validate request
      [seq, ann].each &:reload

      expect(seq).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'There is no corresponding annotation file.'
        ]
      )

      expect(ann).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'There is no corresponding sequence file.'
        ]
      )
    end

    example 'duplicate seq' do
      seq1 = create_seq(request, name: 'foo.fasta')
      seq2 = create_seq(request, name: 'foo.seq')
      ann  = create_ann(request, name: 'foo.ann')

      TradValidator.new.validate request
      [seq1, seq2, ann].each &:reload

      expect(seq1).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'Duplicate sequence files with the same name exist.'
        ]
      )

      expect(seq2).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'Duplicate sequence files with the same name exist.'
        ]
      )

      expect(ann).to have_attributes(
        validity:           'valid',
        validation_details: nil
      )
    end

    example 'combined' do
      seq1 = create_seq(request, name: 'foo.fasta')
      seq2 = create_seq(request, name: 'foo.seq')

      TradValidator.new.validate request
      [seq1, seq2].each &:reload

      expect(seq1).to have_attributes(
        validity: 'invalid',

        validation_details: contain_exactly(
          {
            'severity' => 'error',
            'message'  => 'Duplicate sequence files with the same name exist.'
          },
          {
            'severity' => 'error',
            'message'  => 'There is no corresponding annotation file.'
          }
        )
      )

      expect(seq2).to have_attributes(
        validity: 'invalid',

        validation_details: contain_exactly(
          {
            'severity' => 'error',
            'message'  => 'Duplicate sequence files with the same name exist.'
          },
          {
            'severity' => 'error',
            'message'  => 'There is no corresponding annotation file.'
          }
        )
      )
    end
  end

  describe 'seq' do
    example 'no entries' do
      seq = create_seq(request, content: '')
      ann = create_ann(request)

      TradValidator.new.validate request
      seq.reload

      expect(seq).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'No entries found.'
        ]
      )
    end
  end

  describe 'ann' do
    example 'missing contact person' do
      seq = create_seq(request)
      ann = create_ann(request, content: '')

      TradValidator.new.validate request
      ann.reload

      expect(ann).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'Contact person information (contact, email, institute) is missing.'
        ]
      )
    end

    example 'missing contact person (partial)' do
      seq = create_seq(request)

      ann = create_ann(request, content: <<~ANN)
        COMMON	SUBMITTER		contact	Alice Liddell
        			email	alice@example.com
      ANN

      TradValidator.new.validate request
      ann.reload

      expect(ann).to have_attributes(
        validity: 'invalid',

        validation_details: [
          'severity' => 'error',
          'message'  => 'Contact person information (contact, email, institute) is missing.'
        ]
      )
    end
  end
end
