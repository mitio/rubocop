# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::EndAlignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { {} }
  let(:cop_config) { { 'AlignWith' => 'keyword' } }

  shared_examples 'misaligned' do |alignment_base, arg, end_kw, name|
    name ||= alignment_base
    it "registers an offence for mismatched #{name} ... end" do
      inspect_source(cop, ["#{alignment_base} #{arg}",
                           end_kw])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages.first)
        .to match(/end at 2, \d is not aligned with #{alignment_base} at 1,/)
      expect(cop.highlights.first).to eq('end')
    end
  end

  shared_examples 'aligned' do |alignment_base, arg, end_kw, name|
    name ||= alignment_base
    it "accepts matching #{name} ... end" do
      inspect_source(cop, ["#{alignment_base} #{arg}",
                           end_kw])
      expect(cop.offences).to be_empty
    end
  end

  include_examples 'misaligned', 'class',  'Test',      '  end'
  include_examples 'misaligned', 'module', 'Test',      '  end'
  include_examples 'misaligned', 'def',    'test',      '  end'
  include_examples 'misaligned', 'def',    'Test.test', '  end', 'defs'
  include_examples 'misaligned', 'if',     'test',      '  end'
  include_examples 'misaligned', 'unless', 'test',      '  end'
  include_examples 'misaligned', 'while',  'test',      '  end'
  include_examples 'misaligned', 'until',  'test',      '  end'

  include_examples 'aligned', 'class',  'Test',      'end'
  include_examples 'aligned', 'module', 'Test',      'end'
  include_examples 'aligned', 'def',    'test',      'end'
  include_examples 'aligned', 'def',    'Test.test', 'end', 'defs'
  include_examples 'aligned', 'if',     'test',      'end'
  include_examples 'aligned', 'unless', 'test',      'end'
  include_examples 'aligned', 'while',  'test',      'end'
  include_examples 'aligned', 'until',  'test',      'end'

  it 'can handle ternary if' do
    inspect_source(cop, 'a = cond ? x : y')
    expect(cop.offences).to be_empty
  end

  it 'can handle modifier if' do
    inspect_source(cop, 'a = x if cond')
    expect(cop.offences).to be_empty
  end

  context 'regarding assignment' do
    context 'when AlignWith is keyword' do
      include_examples 'misaligned', 'var = if',     'test', 'end'
      include_examples 'misaligned', 'var = unless', 'test', 'end'
      include_examples 'misaligned', 'var = while',  'test', 'end'
      include_examples 'misaligned', 'var = until',  'test', 'end'

      include_examples 'aligned', 'var = if',     'test', '      end'
      include_examples 'aligned', 'var = unless', 'test', '      end'
      include_examples 'aligned', 'var = while',  'test', '      end'
      include_examples 'aligned', 'var = until',  'test', '      end'
    end

    context 'when AlignWith is variable' do
      let(:cop_config) { { 'AlignWith' => 'variable' } }

      include_examples 'aligned', 'var = if',     'test', 'end'
      include_examples 'aligned', 'var = unless', 'test', 'end'
      include_examples 'aligned', 'var = while',  'test', 'end'
      include_examples 'aligned', 'var = until',  'test', 'end'
      include_examples 'aligned', 'var = until',  'test', 'end.abc.join("")'

      include_examples 'misaligned', 'var = if',     'test', '      end'
      include_examples 'misaligned', 'var = unless', 'test', '      end'
      include_examples 'misaligned', 'var = while',  'test', '      end'
      include_examples 'misaligned', 'var = until',  'test', '      end'
      include_examples 'misaligned', 'var = until',  'test', '      end.join'

      include_examples 'aligned', '@var = if',  'test', 'end'
      include_examples 'aligned', '$var = if',  'test', 'end'
      include_examples 'aligned', 'CNST = if',  'test', 'end'
      include_examples 'aligned', 'var ||= if', 'test', 'end'
      include_examples 'aligned', 'var &&= if', 'test', 'end'
      include_examples 'aligned', 'var += if',  'test', 'end'
    end
  end
end
