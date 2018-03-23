# coding: utf-8
require 'spec_helper'

describe Moip::Assinaturas::Invoice do

  before(:all) do

    FakeWeb.register_uri(
      :get,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/subscriptions/assinatura1/invoices",
      body:   File.join(File.dirname(__FILE__), '..', 'fixtures', 'list_invoices.json'),
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :get,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/13",
      body:   File.join(File.dirname(__FILE__), '..', 'fixtures', 'details_invoice.json'),
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :get,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/not_found",
      body: '',
      status: [404, 'Not found']
    )

    FakeWeb.register_uri(
      :get,
      "https://TOKEN2:KEY2@api.moip.com.br/assinaturas/v1/subscriptions/assinatura2/invoices",
      body:   File.join(File.dirname(__FILE__), '..', 'fixtures', 'custom_authentication', 'list_invoices.json'),
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :get,
      "https://TOKEN2:KEY2@api.moip.com.br/assinaturas/v1/invoices/14",
      body:   File.join(File.dirname(__FILE__), '..', 'fixtures', 'custom_authentication', 'details_invoice.json'),
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/998789/notify",
      body:  '',
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/998779/notify",
      body:  '',
      status: [404, 'not found']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/INV-998789/retry",
      body:  '',
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/INV-998779/retry",
      body:  '',
      status: [404, 'not found']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/INV-998889/boletos",
      body:  File.join(File.dirname(__FILE__), '..', 'fixtures', 'generate_bank_slip.json'),
      status: [200, 'OK']
    )

    FakeWeb.register_uri(
      :post,
      "https://TOKEN:KEY@api.moip.com.br/assinaturas/v1/invoices/INV-998879/boletos",
      body:  '',
      status: [404, 'not found']
    )

  end

  it "should list all invoices from a subscription" do
    request = Moip::Assinaturas::Invoice.list('assinatura1')
    request[:success].should  be_truthy
  end

  describe 'invoice details' do
    it  "should get the invoice details" do
      request = Moip::Assinaturas::Invoice.details(13)
      request[:success].should       be_truthy
      request[:invoice][:id].should  == 13
    end

    it 'should return not found when invoice does not exist' do
      request = Moip::Assinaturas::Invoice.details('not_found')
      request[:success].should       be_falsey
      request[:message].should  == 'not found'
    end
  end

  context "invoice retry" do
    it "should retry invoice" do
      request = Moip::Assinaturas::Invoice.retry "INV-998789"
      expect(request[:success]).to be_truthy
    end

    it "should not retry Invoice" do
      request = Moip::Assinaturas::Invoice.retry "INV-998779"
      expect(request[:success]).to be_falsey
    end
  end

  context "generate new invoice bank slip" do
    it "should generate bank slip" do
      request = Moip::Assinaturas::Invoice.generate_slip "INV-998889", { day: 1, month: 8, year: 2020 }
      expect(request[:success]).to be_truthy
      expect(request[:bank_slip][:due_date][:day]).to eq 1
      expect(request[:bank_slip][:due_date][:month]).to eq 8
      expect(request[:bank_slip][:due_date][:year]).to eq 2020
    end

    it "should not generate bank slip" do
      request = Moip::Assinaturas::Invoice.generate_slip "INV-998879"
      expect(request[:success]).to be_falsey
    end
  end

  context "invoice notify" do
    it "should notify invoice" do
      request = Moip::Assinaturas::Invoice.notify "998789"
      expect(request[:success]).to be_truthy
    end

    it "should not notify Invoice" do
      request = Moip::Assinaturas::Invoice.notify "998779"
      expect(request[:success]).to be_falsey
    end
  end

  context "Custom Authentication" do
    it "should list all invoices from a subscription from a custom moip account" do
      request = Moip::Assinaturas::Invoice.list('assinatura2', moip_auth: $custom_moip_auth)
      request[:success].should  be_truthy
    end

    it  "should get the invoice details from a custom moip account" do
      request = Moip::Assinaturas::Invoice.details(14, moip_auth: $custom_moip_auth)
      request[:success].should       be_truthy
      request[:invoice][:id].should  == 14
    end
  end

end
