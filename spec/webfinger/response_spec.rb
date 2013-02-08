require 'spec_helper'

describe WebFinger::Response do
  let(:_subject_) { 'acct:nov@matake.jp' }
  let(:aliases) { ['mailto:nov@matake.jp'] }
  let(:properties) do
    {'http://webfinger.net/rel/name' => 'Nov Matake'}
  end
  let(:links) do
    [{
      rel: 'http://openid.net/specs/connect/1.0/issuer',
      href: 'https://openid.example.com/'
    }]
  end
  subject do
    WebFinger::Response.new(
      subject: _subject_,
      aliases: aliases,
      properties: properties,
      links: links
    )
  end

  its(:subject)    { should == subject }
  its(:aliases)    { should == aliases }
  its(:properties) { should == properties }
  its(:links)      { should == links }
end