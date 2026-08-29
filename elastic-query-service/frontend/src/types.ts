// Mirrors elastic-query-service's REST DTOs (ElasticQueryServiceResponseModel[V2] extend
// Spring HATEOAS's RepresentationModel, which adds "_links" on serialization).

export interface HalLinks {
  _links?: Record<string, { href: string }>;
}

export interface ElasticQueryServiceResponseModel extends HalLinks {
  id: string;
  userId: number;
  text: string;
  createdAt: string;
}

export interface ElasticQueryServiceResponseModelV2 extends HalLinks {
  id: number;
  userId: number;
  text: string;
  text2: string;
}

export interface ErrorDTO {
  code: string;
  message: string;
}
