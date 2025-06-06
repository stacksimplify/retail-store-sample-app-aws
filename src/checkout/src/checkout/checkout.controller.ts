/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import {
  Body,
  Controller,
  Get,
  NotFoundException,
  Param,
  Post,
} from '@nestjs/common';
import { CheckoutService } from './checkout.service';
import { Checkout } from './models/Checkout';
import { CheckoutRequest } from './models/CheckoutRequest';
import { CheckoutSubmitted } from './models/CheckoutSubmitted';
import { ApiCreatedResponse } from '@nestjs/swagger';

@Controller('checkout')
export class CheckoutController {
  constructor(private readonly checkoutService: CheckoutService) {}

  @Get(':customerId')
  @ApiCreatedResponse({
    description: 'The record has been successfully created.',
    type: Checkout,
  })
  async getCheckout(
    @Param('customerId') customerId: string,
  ): Promise<Checkout> {
    const checkout = this.checkoutService.get(customerId);

    return checkout.then(function (data) {
      if (!data) {
        throw new NotFoundException('Checkout not found');
      }

      return data;
    });
  }

  @Post(':customerId/update')
  @ApiCreatedResponse({
    description: 'The record has been successfully created.',
    type: Checkout,
  })
  async updateCheckout(
    @Param('customerId') customerId: string,
    @Body() request: CheckoutRequest,
  ): Promise<Checkout> {
    return this.checkoutService.update(customerId, request);
  }

  @Post(':customerId/submit')
  @ApiCreatedResponse({
    description: 'The record has been successfully created.',
    type: CheckoutSubmitted,
  })
  async submitCheckout(
    @Param('customerId') customerId: string,
  ): Promise<CheckoutSubmitted> {
    return this.checkoutService.submit(customerId);
  }
}
